#!/usr/bin/env zsh
# Standalone synthetic media regression suite; backend output never enters reports.
emulate -LR zsh
setopt no_unset pipe_fail
root=${0:A:h:h}
work=$(mktemp -d "$root/tests/.media.XXXXXXXX") || exit 1
trap '/bin/rm -rf -- "$work"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
(
export HOME="$work/home" TMPDIR="$work/tmp" LANG=C LC_ALL=C
mkdir -p "$HOME" "$TMPDIR" "$work/fixtures"
path=(/usr/bin /bin /usr/sbin /sbin)
source "$root/zshlib/media.zsh" || exit 1
integer passed=0 failed=0
check() {
  local label=$1
  shift
  mkdir "$work/case-$((passed+failed))"
  if (cd "$work/case-$((passed+failed))" && "$@") >"$work/result" 2>&1; then
    print -r -- "ok - $label"
    (( ++passed ))
  else
    print -r -- "not ok - $label"
    (( ++failed ))
  fi
}
run_media() {
  "$@" >"$work/stdout" 2>"$work/stderr"
  result=$?
}
summary() { [[ $(<"$work/stdout") == *"media: $1 converted, $2 skipped, $3 failed"* ]] }
probe() { command ffprobe -v error -select_streams "$1" -show_entries "stream=$2" -of default=nw=1:nk=1 "$3" 2>/dev/null }
fixtures() {
  command ffmpeg -v error -f lavfi -i anullsrc=r=48000:cl=stereo -t 0.2 "$work/fixtures/stereo.wav" || return
  command ffmpeg -v error -f lavfi -i anullsrc=r=48000:cl=5.1 -t 0.2 "$work/fixtures/surround.wav" || return
  command ffmpeg -v error -f lavfi -i color=c=blue:s=64x48:r=5 -t 0.2 -c:v libx264 -pix_fmt yuv420p "$work/fixtures/video.mkv" || return
  command magick -size 120x60 xc:blue "$work/fixtures/image.png" || return
  command magick -size 40x80 xc:blue "$work/fixtures/portrait.png" || return
  command magick -size 8x4 xc:none "$work/fixtures/alpha.png" || return
  command magick -size 8x4 xc:red -size 8x4 xc:blue -loop 0 "$work/fixtures/animation.gif"
}
if ! fixtures >"$work/result" 2>&1; then
  print -r -- 'not ok - Media_Fixtures_RequiredLocalEncodersAvailable'
  exit 1
fi
AudioBatch_MixedDirectSources_SnapshotOnly() {
  cp "$work/fixtures/stereo.wav" './sample one.wav'
  cp "$work/fixtures/stereo.wav" ./-sample.wav
  mkdir nested
  cp "$work/fixtures/stereo.wav" nested/deep.wav
  print -r -- 'not media' > note.txt
  run_media to-mp3
  (( result == 0 )) && summary 2 0 0 && [[ -s 'sample one.mp3' && -s ./-sample.mp3 && ! -e nested/deep.mp3 && ! -e note.mp3 ]]
}
AudioList_ExplicitSubset_LeavesOthersUntouched() {
  cp "$work/fixtures/stereo.wav" one.wav
  cp "$work/fixtures/stereo.wav" two.wav
  run_media to-opus -- one.wav
  (( result == 0 )) && summary 1 0 0 && [[ -s one.opus && ! -e two.opus ]] && cmp -s one.wav "$work/fixtures/stereo.wav"
}
AudioCodecs_NormalStereo_ExpectedCodecs() {
  local target codec extension
  for target codec extension in mp3 mp3 mp3 opus opus opus aac aac m4a flac flac flac alac alac m4a; do
    cp "$work/fixtures/stereo.wav" "$target.wav"
    run_media "to-$target" "$target.wav"
    (( result == 0 )) && [[ $(probe a:0 codec_name "$target.$extension") == $codec ]] || return 1
  done
}
AudioCollision_ExistingM4a_PreservesBoth() {
  cp "$work/fixtures/stereo.wav" clip.wav
  print -r -- sentinel > clip.m4a
  run_media to-alac clip.wav
  (( result == 0 )) && summary 0 1 0 && [[ $(<clip.m4a) == sentinel ]] && cmp -s clip.wav "$work/fixtures/stereo.wav"
}
AudioComplex_SurroundLossy_RejectsWithoutDownmix() {
  cp "$work/fixtures/surround.wav" clip.wav
  run_media to-opus clip.wav
  (( result == 1 )) && [[ ! -e clip.opus ]] || return 1
  run_media to-flac clip.wav
  (( result == 0 )) && [[ $(probe a:0 channels clip.flac) == 6 ]]
}
ImageFormats_NormalSingleFrame_ValidOutput() {
  local format
  for format in jpg png webp avif; do
    command magick "$work/fixtures/image.png" "$format.bmp" || return
    run_media "to-$format" "$format.bmp"
    (( result == 0 )) && [[ -s "$format.$format" ]] || return 1
    command magick identify "$format.$format" >/dev/null 2>&1 || return
  done
}
ImageComplex_AnimationAndJpegAlpha_NoFlatten() {
  cp "$work/fixtures/alpha.png" alpha.png
  cp "$work/fixtures/animation.gif" animated.gif
  run_media to-jpg alpha.png animated.gif
  (( result == 1 )) && [[ ! -e alpha.jpg && ! -e animated.jpg ]]
}
Resize_BoxesAndSmallSources_PreservesShape() {
  local preset expected
  for preset expected in 4k 120x60 2k 120x60 fullhd 120x60 40x40 40x20; do
    cp "$work/fixtures/image.png" "$preset.png"
    run_media imgresize "$preset" "$preset.png"
    (( result == 0 )) && [[ $(command magick identify -format '%wx%h' "$preset-$preset.png") == "$expected" ]] || return 1
  done
  cp "$work/fixtures/portrait.png" portrait.png
  run_media imgresize 40x40 portrait.png
  (( result == 0 )) && [[ $(command magick identify -format '%wx%h' portrait-40x40.png) == 20x40 ]]
}
Resize_AutomaticRepeat_SkipsGeneratedOutputs() {
  cp "$work/fixtures/image.png" sample.png
  run_media imgresize fullhd
  (( result == 0 )) && summary 1 0 0 || return 1
  run_media imgresize fullhd
  (( result == 0 )) && [[ ! -e sample-fullhd-fullhd.png ]]
}
Usage_InvalidDimensionsAndOptions_ReturnsTwo() {
  local argument
  for argument in 0x20 20x0 -1x20 invalid; do
    run_media imgresize "$argument"
    (( result == 2 )) || return 1
  done
  run_media to-mp3 --unknown
  (( result == 2 ))
}
Video_NormalSdr_PreservesDimensionsAndCodec() {
  cp "$work/fixtures/video.mkv" sample.mkv
  run_media to-mp4 sample.mkv
  (( result == 0 )) && [[ $(probe v:0 codec_name sample.mp4) == h264 && $(probe v:0 width sample.mp4) == 64 && $(probe v:0 height sample.mp4) == 48 ]]
}
Batch_ExplicitFailure_ContinuesAndRedactsNames() {
  cp "$work/fixtures/stereo.wav" good.wav
  print -r -- malformed > 'private-marker.wav'
  run_media to-mp3 'private-marker.wav' good.wav
  (( result == 1 )) && [[ -s good.mp3 && ! -e private-marker.mp3 && $(<"$work/stderr") != *private-marker* && $(<"$work/stdout") != *private-marker* ]]
}
Dependency_AbsentBackend_Returns127() {
  cp "$work/fixtures/stereo.wav" sample.wav
  path=()
  run_media to-mp3 sample.wav
  (( result == 127 ))
}
# The stub delegates capability discovery but simulates encode failure/publication races.
encoder_stub() {
  mkdir bin
  cat > bin/ffmpeg <<'STUB'
#!/bin/sh
for arg do
  [ "$arg" != '-encoders' ] || exec /usr/bin/ffmpeg "$@"
  output=$arg
done
case "$MEDIA_TEST_MODE" in
  failure) printf partial > "$output"; exit 1 ;;
  race) printf sentinel > "$MEDIA_TEST_TARGET" ;;
  directory) mkdir "$MEDIA_TEST_TARGET" ;;
  signal) printf partial > "$output"; kill -TERM "$PPID"; exit 1 ;;
esac
printf synthetic > "$output"
exit 0
STUB
  chmod +x bin/ffmpeg
  path=("$PWD/bin" $path)
}
Encoder_FailureAndRace_NoPartialOrClobber() {
  cp "$work/fixtures/stereo.wav" sample.wav
  encoder_stub
  local mode
  for mode in failure race directory; do
    export MEDIA_TEST_MODE=$mode MEDIA_TEST_TARGET="$PWD/sample.mp3"
    run_media to-mp3 sample.wav
    cmp -s sample.wav "$work/fixtures/stereo.wav" || return
    case $mode in
      failure) (( result == 1 )) && [[ ! -e sample.mp3 ]] || return 1 ;;
      race) [[ $(<sample.mp3) == sentinel ]] || return 1; rm sample.mp3 ;;
      directory) [[ -d sample.mp3 && -z $(command ls -A sample.mp3) ]] || return 1; rmdir sample.mp3 ;;
    esac
    local -a leftovers=( .*(N) )
    (( ${#leftovers} == 0 )) || return 1
  done
}
Encoder_Terminated_NoPartialOrStaging() {
  cp "$work/fixtures/stereo.wav" sample.wav
  encoder_stub
  export MEDIA_TEST_MODE=signal
  ( to-mp3 sample.wav ) >"$work/stdout" 2>"$work/stderr"
  local rc=$?
  local -a leftovers=( .*(N) )
  (( rc != 0 && ${#leftovers} == 0 )) && [[ ! -e sample.mp3 ]] && cmp -s sample.wav "$work/fixtures/stereo.wav"
}
Video_ComplexTracksAndHdr_NoSilentStreamLoss() {
  command ffmpeg -v error -i "$work/fixtures/video.mkv" -i "$work/fixtures/stereo.wav" -map 0:v -map 1:a -map 1:a -c copy multiple.mkv || return
  run_media to-mp4 multiple.mkv
  (( result == 1 )) && [[ ! -e multiple.mp4 ]] || return 1
  command ffmpeg -v error -i "$work/fixtures/video.mkv" -c copy -color_trc smpte2084 hdr.mkv || return
  run_media to-mp4 hdr.mkv
  (( result == 1 )) && [[ ! -e hdr.mp4 ]]
}
Audio_BitrateDefaults_ExactFlags() {
  cp "$work/fixtures/stereo.wav" sample.wav
  mkdir bin
  cat > bin/ffmpeg <<'STUB'
#!/bin/sh
for arg do
  [ "$arg" != '-encoders' ] || exec /usr/bin/ffmpeg "$@"
done
codec= bitrate= vbr=
while [ "$#" -gt 0 ]; do
  case "$1" in
    -c:a|-codec:a) shift; codec=$1 ;;
    -b:a) shift; bitrate=$1 ;;
    -vbr) shift; vbr=$1 ;;
  esac
  output=$1
  shift
done
case "$MEDIA_TEST_FORMAT:$codec:$bitrate:$vbr" in
  mp3:libmp3lame:256k:|aac:aac:256k:|opus:libopus:192k:on) ;;
  *) exit 1 ;;
esac
printf synthetic > "$output"
STUB
  chmod +x bin/ffmpeg
  path=("$PWD/bin" $path)
  local format
  for format in mp3 opus aac; do
    export MEDIA_TEST_FORMAT=$format
    run_media "to-$format" sample.wav
    (( result == 0 )) && summary 1 0 0 || return 1
  done
}
Video_BatchDifferentContainer_ConvertsDirectSources() {
  cp "$work/fixtures/video.mkv" sample.mkv
  mkdir nested
  cp "$work/fixtures/video.mkv" nested/inside.mkv
  run_media to-mp4
  (( result == 0 )) && summary 1 0 0 && [[ -s sample.mp4 && ! -e nested/inside.mp4 ]]
}
Image_ListWithShellCharacters_NoEvaluation() {
  local name='sample;$(touch unexpected).png'
  cp "$work/fixtures/image.png" "$name"
  cp "$work/fixtures/image.png" ./-sample.png
  cp "$work/fixtures/image.png" untouched.png
  run_media to-webp -- "$name" -sample.png
  (( result == 0 )) && summary 2 0 0 && [[ -s "${name:r}.webp" && -s ./-sample.webp && ! -e untouched.webp && ! -e unexpected ]]
}
Video_QualityDefaults_ExactEncoderFlags() {
  cp "$work/fixtures/video.mkv" sample.mkv
  mkdir bin
  cat > bin/ffmpeg <<'STUB'
#!/bin/sh
for arg do
  [ "$arg" != '-encoders' ] || exec /usr/bin/ffmpeg "$@"
done
codec= crf= preset= audio= bitrate= tag=
while [ "$#" -gt 0 ]; do
  case "$1" in
    -c:v) shift; codec=$1 ;;
    -crf) shift; crf=$1 ;;
    -preset) shift; preset=$1 ;;
    -c:a) shift; audio=$1 ;;
    -b:a) shift; bitrate=$1 ;;
    -tag:v) shift; tag=$1 ;;
  esac
  output=$1
  shift
done
case "$MEDIA_TEST_FORMAT:$codec:$crf:$preset:$audio:$bitrate:$tag" in
  mp4:libx264:20:medium:aac:256k:|hevc:libx265:24:medium:aac:256k:hvc1|av1:libsvtav1:28:6:aac:256k:) ;;
  *) exit 1 ;;
esac
printf synthetic > "$output"
STUB
  chmod +x bin/ffmpeg
  path=("$PWD/bin" $path)
  local format
  for format in mp4 hevc av1; do
    export MEDIA_TEST_FORMAT=$format
    cp "$work/fixtures/video.mkv" "$format.mkv"
    run_media "to-$format" "$format.mkv"
    (( result == 0 )) && summary 1 0 0 || return 1
  done
  [[ -s av1-av1.mkv ]] || return 1
  mkdir auto
  cd auto
  command /usr/bin/ffmpeg -v error -i "$work/fixtures/video.mkv" -c copy sample.mp4 || return
  export MEDIA_TEST_FORMAT=hevc
  run_media to-hevc
  (( result == 0 )) && summary 1 0 0 && [[ -s sample-hevc.mp4 ]]
}
Image_DisguisedDocument_RejectsBeforeRendering() {
  print -r -- '<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10"><rect width="10" height="10"/></svg>' > sample.png
  cp sample.png expected
  run_media to-webp sample.png
  (( result == 1 )) && [[ ! -e sample.webp ]] && cmp -s sample.png expected
}
Batch_SymlinkSourceAndDanglingOutput_PreservesLinks() {
  cp "$work/fixtures/stereo.wav" original.wav
  ln -s original.wav linked.wav
  run_media to-mp3 linked.wav
  (( result == 1 )) && [[ -L linked.wav && ! -e linked.mp3 ]] || return 1
  ln -s absent original.mp3
  run_media to-mp3 original.wav
  (( result == 0 )) && summary 0 1 0 && [[ -L original.mp3 && ! -e absent ]] && cmp -s original.wav "$work/fixtures/stereo.wav"
}
Lossless_PcmPrecision_PreservesOrRejects() {
  local pcm target extension
  for pcm in s16le s24le s32le f32le f64le; do
    command ffmpeg -v error -f lavfi -i 'aevalsrc=0.123456789*sin(2*PI*997*t):s=48000' -t 0.1 -c:a "pcm_$pcm" "$pcm.wav" || return
    for target extension in flac flac alac m4a; do
      run_media "to-$target" "$pcm.wav"
      if [[ $pcm == s16le || $pcm == s24le ]]; then
        (( result == 0 )) || return 1
        command ffmpeg -v error -i "$pcm.wav" -f s32le -c:a pcm_s32le -y original.pcm || return
        command ffmpeg -v error -i "$pcm.$extension" -f s32le -c:a pcm_s32le -y decoded.pcm || return
        cmp -s original.pcm decoded.pcm || return 1
        [[ $(probe a:0 sample_rate "$pcm.$extension") == 48000 ]] || return 1
      else
        (( result == 1 )) && [[ ! -e "$pcm.$extension" ]] || return 1
      fi
    done
  done
}
Image_SourceDisappears_NoRawPath() {
  cp "$work/fixtures/image.png" source.png
  mkdir bin
  cat > bin/magick <<'STUB'
#!/bin/sh
if [ "$1" = identify ]; then
  rm -- "$MEDIA_RACE_SOURCE"
  printf 'PNG|1|true\n'
else
  exit 9
fi
STUB
  chmod +x bin/magick
  export MEDIA_RACE_SOURCE="$PWD/source.png"
  path=("$PWD/bin" $path)
  run_media to-webp source.png
  (( result == 1 )) && [[ ! -e source.webp ]] || return 1
  [[ $(<"$work/stderr") == 'media: item 1 failed (input, encoder or output error)' ]] || return 1
  local -a staging=(.zsh-media.*(ND))
  (( ${#staging} == 0 ))
}
check PM01_Lossless_PcmPrecision_PreservesOrRejects Lossless_PcmPrecision_PreservesOrRejects
check PM02_Image_SourceDisappears_NoRawPath Image_SourceDisappears_NoRawPath
check AK13_Image_DisguisedDocument_RejectsBeforeRendering Image_DisguisedDocument_RejectsBeforeRendering
check AK12_Batch_SymlinkSourceAndDanglingOutput_PreservesLinks Batch_SymlinkSourceAndDanglingOutput_PreservesLinks
check AK11_Video_BatchDifferentContainer_ConvertsDirectSources Video_BatchDifferentContainer_ConvertsDirectSources
check AK11_Image_ListWithShellCharacters_NoEvaluation Image_ListWithShellCharacters_NoEvaluation
check AK13_Video_QualityDefaults_ExactEncoderFlags Video_QualityDefaults_ExactEncoderFlags
check AK12_Encoder_FailureAndRace_NoPartialOrClobber Encoder_FailureAndRace_NoPartialOrClobber
check AK12_Encoder_Terminated_NoPartialOrStaging Encoder_Terminated_NoPartialOrStaging
check AK13_Video_ComplexTracksAndHdr_NoSilentStreamLoss Video_ComplexTracksAndHdr_NoSilentStreamLoss
check AK13_Audio_BitrateDefaults_ExactFlags Audio_BitrateDefaults_ExactFlags
check AK11_AudioBatch_MixedDirectSources_SnapshotOnly AudioBatch_MixedDirectSources_SnapshotOnly
check AK11_AudioList_ExplicitSubset_LeavesOthersUntouched AudioList_ExplicitSubset_LeavesOthersUntouched
check AK13_AudioCodecs_NormalStereo_ExpectedCodecs AudioCodecs_NormalStereo_ExpectedCodecs
check AK12_AudioCollision_ExistingM4a_PreservesBoth AudioCollision_ExistingM4a_PreservesBoth
check AK13_AudioComplex_SurroundLossy_RejectsWithoutDownmix AudioComplex_SurroundLossy_RejectsWithoutDownmix
check AK13_ImageFormats_NormalSingleFrame_ValidOutput ImageFormats_NormalSingleFrame_ValidOutput
check AK13_ImageComplex_AnimationAndJpegAlpha_NoFlatten ImageComplex_AnimationAndJpegAlpha_NoFlatten
check AK14_Resize_BoxesAndSmallSources_PreservesShape Resize_BoxesAndSmallSources_PreservesShape
check AK14_Resize_AutomaticRepeat_SkipsGeneratedOutputs Resize_AutomaticRepeat_SkipsGeneratedOutputs
check AK14_Usage_InvalidDimensionsAndOptions_ReturnsTwo Usage_InvalidDimensionsAndOptions_ReturnsTwo
check AK13_Video_NormalSdr_PreservesDimensionsAndCodec Video_NormalSdr_PreservesDimensionsAndCodec
check AK11_Batch_ExplicitFailure_ContinuesAndRedactsNames Batch_ExplicitFailure_ContinuesAndRedactsNames
check AK13_Dependency_AbsentBackend_Returns127 Dependency_AbsentBackend_Returns127
print -r -- "media tests: $passed passed, $failed failed"
(( failed == 0 ))
)
