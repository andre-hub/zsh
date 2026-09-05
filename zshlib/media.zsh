# Optional backends are checked on invocation, never during shell startup.
_zmedia_probe() {
  emulate -L zsh
  local report line field key value kind channels pixel transfer primaries codec video_codec sample_fmt raw_bits
  integer audio=0 video=0 other=0 unsafe=0
  report=$(command ffprobe -v error -protocol_whitelist file,pipe \
    -show_entries stream=codec_type,codec_name,channels,sample_fmt,bits_per_raw_sample,pix_fmt,color_transfer,color_primaries:stream_disposition=attached_pic:stream_side_data=side_data_type \
    -of 'compact=p=0:nk=0' "$1" 2>/dev/null) || return 1
  for line in "${(@f)report}"; do
    kind= channels= pixel= transfer= primaries= codec= sample_fmt= raw_bits=
    for field in "${(@s:|:)line}"; do
      key=${field%%=*} value=${field#*=}
      case $key in
        codec_type) kind=$value ;;
        codec_name) codec=$value ;;
        channels) channels=$value ;;
        sample_fmt) sample_fmt=$value ;;
        bits_per_raw_sample) raw_bits=$value ;;
        pix_fmt) pixel=$value ;;
        color_transfer) transfer=$value ;;
        color_primaries) primaries=$value ;;
        disposition:attached_pic) [[ $value == 1 ]] && (( ++unsafe )) ;;
        side_data_type) [[ $value == *[Dd]olby* || $value == *DOVI* || $value == *[Mm]astering* || $value == *[Ll]ight* ]] && (( ++unsafe )) ;;
      esac
    done
    case $kind in
      audio)
        (( ++audio ))
        [[ $channels == <-> ]] && (( channels > 0 )) || return 1
        if [[ $2 == flac || $2 == alac ]]; then
          # These encoders cannot preserve floating-point or full-width PCM32 samples.
          case $sample_fmt in
            u8|u8p|s16|s16p) ;;
            s32|s32p) [[ $raw_bits == <-> ]] && (( raw_bits > 0 && raw_bits <= 24 )) || return 4 ;;
            *) return 4 ;;
          esac
        else
          (( channels <= 2 )) || (( ++unsafe ))
        fi
        ;;
      video)
        (( ++video )); video_codec=$codec
        [[ $transfer == smpte2084 || $transfer == arib-std-b67 || $primaries == bt2020 ]] && (( ++unsafe ))
        # Reject high-depth/ambiguous colour rather than silently tone-map it.
        [[ $pixel == yuv420p || $pixel == yuv422p || $pixel == yuv444p || $pixel == yuvj420p || $pixel == yuvj422p || $pixel == yuvj444p || $pixel == rgb24 || $pixel == bgr24 || $pixel == gray ]] || (( ++unsafe ))
        ;;
      '') ;;
      *) (( ++other )) ;;
    esac
  done
  if [[ $3 == video ]]; then
    (( video == 1 && audio <= 1 && other == 0 && unsafe == 0 )) || return 4
    if [[ $4 == 1 ]]; then
      case $2:$video_codec:${1:e:l} in mp4:h264:mp4|hevc:hevc:mp4|av1:av1:mkv) return 3 ;; esac
    fi
  else
    # Audio extraction intentionally discards video, but never chooses among tracks.
    (( audio == 1 )) || return 4
    if [[ $2 != flac && $2 != alac ]]; then
      report=$(command ffprobe -v error -protocol_whitelist file,pipe -select_streams a \
        -show_entries stream=channels -of csv=p=0 "$1" 2>/dev/null) || return 1
      [[ $report == <-> ]] && (( report <= 2 )) || return 4
    fi
  fi
}

_zmedia_one() (
  emulate -LR zsh
  setopt localtraps
  local mode=$1 group=$2 input=$3 output=$4 box=$5 automatic=$6 stage='' report format input_coder
  local -a image_tool identify_tool opts info
  trap '[[ -z $stage ]] || command rm -rf -- "$stage"' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
  [[ ! -e $output && ! -L $output ]] || return 3
  [[ -f $input && ! -L $input && -r $input ]] || return 1
  if [[ $group == image ]]; then
    if (( $+commands[magick] )); then
      image_tool=(magick) identify_tool=(magick identify)
    else
      image_tool=(convert) identify_tool=(identify)
    fi
    case ${input:e:l} in
      jpg|jpeg) input_coder=JPEG ;; png) input_coder=PNG ;; webp) input_coder=WEBP ;;
      avif) input_coder=AVIF ;; heic|heif) input_coder=HEIC ;; tif|tiff) input_coder=TIFF ;;
      bmp) input_coder=BMP ;; gif) input_coder=GIF ;; *) return 4 ;;
    esac
    # A fixed raster decoder also prevents disguised SVG/PDF delegates.
    # stdin avoids ImageMagick's filename coders, percent templates and [selectors].
    report=$(command "${identify_tool[@]}" -format '%m|%n|%[opaque]\n' "${input_coder}:-" 2>/dev/null < "$input") || return 1
    info=("${(@f)report}")
    (( ${#info} == 1 )) || return 4
    info=("${(@s:|:)report}")
    [[ ${info[2]} == 1 ]] || return 4
    case ${info[1]} in JPEG|PNG|WEBP|AVIF|HEIC|TIFF|BMP|GIF) ;; *) return 4 ;; esac
    [[ $mode != jpg || ${info[3]:l} == true ]] || return 4
    opts=(-auto-orient)
    case $mode in
      jpg) format=JPEG; opts+=(-quality 92) ;;
      png) format=PNG ;;
      webp) format=WEBP; opts+=(-quality 90) ;;
      avif) format=AVIF; opts+=(-quality 60) ;;
      resize) format=${info[1]}; opts+=(-resize "${box}>") ;;
    esac
  else
    _zmedia_probe "$input" "$mode" "$group" "$automatic" || return $?
    case $mode in
      mp3) opts=(-map 0:a:0 -vn -c:a libmp3lame -b:a 256k -f mp3) ;;
      opus) opts=(-map 0:a:0 -vn -c:a libopus -b:a 192k -vbr on -f opus) ;;
      aac) opts=(-map 0:a:0 -vn -c:a aac -b:a 256k -f ipod) ;;
      flac) opts=(-map 0:a:0 -vn -c:a flac -f flac) ;;
      alac) opts=(-map 0:a:0 -vn -c:a alac -f ipod) ;;
      mp4|hevc|av1)
        opts=(-map 0:v:0 -map '0:a:0?' -c:a aac -b:a 256k -pix_fmt yuv420p)
        case $mode in
          mp4) opts+=(-c:v libx264 -crf 20 -preset medium -movflags +faststart -f mp4) ;;
          hevc) opts+=(-c:v libx265 -crf 24 -preset medium -tag:v hvc1 -movflags +faststart -f mp4) ;;
          av1) opts+=(-c:v libsvtav1 -crf 28 -preset 6 -f matroska) ;;
        esac
        ;;
    esac
  fi
  # Same-filesystem staging + link(2): even a racing directory/symlink cannot be replaced.
  stage=$(command mktemp -d "${output:h}/.zsh-media.XXXXXXXX" 2>/dev/null) || return 1
  if [[ $group == image ]]; then
    command "${image_tool[@]}" "${input_coder}:-" "${opts[@]}" "${format}:-" 2>/dev/null < "$input" > "$stage/result" || return 1
  else
    command ffmpeg -nostdin -hide_banner -loglevel error -n -protocol_whitelist file,pipe \
      -i "$input" "${opts[@]}" "$stage/result" >/dev/null 2>&1 || return 1
  fi
  [[ -s $stage/result ]] || return 1
  command link "$stage/result" "$output" 2>/dev/null || {
    [[ -e $output || -L $output ]] && return 3
    return 1
  }
)

_zmedia_batch() {
  emulate -L zsh
  setopt extendedglob
  local mode=$1 group extension size='' box='' input suffix output ext encoder encoders
  integer automatic=0 converted=0 skipped=0 failed=0 index=0 rc
  local -a files
  shift
  case $mode in
    mp3|opus|flac) group=audio; extension=$mode ;;
    aac|alac) group=audio; extension=m4a ;;
    mp4|hevc) group=video; extension=mp4 ;;
    av1) group=video; extension=mkv ;;
    jpg|png|webp|avif) group=image; extension=$mode ;;
    resize)
      group=image; size=${1-}; (( $# )) && shift
      case $size in
        4k) box=3840x2160 ;;
        2k) box=2560x1440 ;;
        fullhd) box=1920x1080 ;;
        <->x<->)
          local width=${size%x*} height=${size#*x}
          # Keep arithmetic bounded and exclude zero, signs and leading-zero ambiguity.
          [[ ${#width} -le 6 && ${#height} -le 6 && $width != 0* && $height != 0* ]] && box=$size ;;
      esac
      [[ -n $box ]] || { print -u2 'media: expected 4k, 2k, fullhd or positive WxH'; return 2; }
      ;;
    *) return 2 ;;
  esac
  if [[ ${1-} == -- ]]; then
    shift
  else
    for input in "$@"; do
      [[ $input != -* ]] || { print -u2 'media: use -- before filenames beginning with a dash'; return 2; }
    done
  fi
  if (( $# )); then files=("$@"); else automatic=1; files=(./*(ND.)); fi
  if [[ $group == image ]]; then
    (( $+commands[magick] || ($+commands[convert] && $+commands[identify]) )) || {
      print -u2 'media: ImageMagick is required'; return 127
    }
  else
    (( $+commands[ffmpeg] && $+commands[ffprobe] )) || {
      print -u2 'media: ffmpeg and ffprobe are required'; return 127
    }
    case $mode in
      mp3) encoder=libmp3lame ;; opus) encoder=libopus ;; aac) encoder=aac ;;
      flac) encoder=flac ;; alac) encoder=alac ;; mp4) encoder=libx264 ;;
      hevc) encoder=libx265 ;; av1) encoder=libsvtav1 ;;
    esac
    encoders=$(command ffmpeg -hide_banner -encoders 2>/dev/null) || return 1
    [[ $encoders == *" $encoder "* ]] && { [[ $group != video || $encoders == *' aac '* ]]; } || {
      print -u2 'media: required encoder is unavailable'; return 127
    }
  fi
  (( $+commands[link] && $+commands[mktemp] )) || {
    print -u2 'media: link and mktemp are required'; return 127
  }
  for input in "${files[@]}"; do
    (( ++index ))
    ext=${input:e:l}
    if (( automatic )); then
      case $group:$ext in
        image:jpg|image:jpeg|image:png|image:webp|image:avif|image:heic|image:heif|image:tif|image:tiff|image:bmp|image:gif) ;;
        audio:wav|audio:flac|audio:mp3|audio:opus|audio:ogg|audio:m4a|audio:aac|audio:aiff|audio:aif|audio:alac|audio:wma|audio:mp4|audio:mkv|audio:mov|audio:webm|audio:avi|audio:m4v) ;;
        video:mp4|video:mkv|video:mov|video:webm|video:avi|video:m4v|video:mpg|video:mpeg|video:ts|video:mts|video:m2ts) ;;
        *) continue ;;
      esac
      if [[ $mode == resize ]]; then
        suffix=${input:t:r}
        if [[ $suffix == *-(4k|2k|fullhd|<->x<->) ]]; then (( ++skipped )); continue; fi
      elif [[ $group != video && ($ext == $extension || ($mode == jpg && $ext == jpeg)) ]]; then
        (( ++skipped )); continue
      fi
    fi
    # :a produces an absolute path without resolving away an explicit input symlink.
    input=${input:a}
    if [[ $mode == resize ]]; then
      output="${input:r}-${size}.${input:e}"
    else
      output="${input:r}.${extension}"
      if [[ $group == video && $ext == $extension ]]; then output="${input:r}-${mode}.${extension}"; fi
    fi
    if _zmedia_one "$mode" "$group" "$input" "$output" "$box" "$automatic"; then rc=0; else rc=$?; fi
    case $rc in
      0) (( ++converted )) ;;
      3) (( ++skipped )) ;;
      4)
        if (( automatic )); then (( ++skipped )); else (( ++failed )); fi
        print -u2 -- "media: item $index skipped (unsupported media structure)"
        ;;
      130|143) print -u2 'media: interrupted'; return $rc ;;
      *) (( ++failed )); print -u2 -- "media: item $index failed (input, encoder or output error)" ;;
    esac
  done
  print -r -- "media: $converted converted, $skipped skipped, $failed failed"
  (( failed == 0 ))
}

to-mp3() { _zmedia_batch mp3 "$@"; }
to-opus() { _zmedia_batch opus "$@"; }
to-aac() { _zmedia_batch aac "$@"; }
to-flac() { _zmedia_batch flac "$@"; }
to-alac() { _zmedia_batch alac "$@"; }
to-mp4() { _zmedia_batch mp4 "$@"; }
to-hevc() { _zmedia_batch hevc "$@"; }
to-av1() { _zmedia_batch av1 "$@"; }
to-jpg() { _zmedia_batch jpg "$@"; }
to-png() { _zmedia_batch png "$@"; }
to-webp() { _zmedia_batch webp "$@"; }
to-avif() { _zmedia_batch avif "$@"; }
imgresize() { _zmedia_batch resize "$@"; }
