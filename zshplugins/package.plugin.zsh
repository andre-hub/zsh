
  function packagelist() {
    Y=`date +%Y-%m-%d`
    # sudo dpkg -l | grep ^ii | awk '{print $2}' > ~/paket-liste
    pacman -Q | grep -v lib | grep -v python | grep -v perl | \
    sed 's/ [0-9].[0-9].[0-9][a-z]_git[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]/ /' | \
    sed 's/ [0-9].[0-9].[0-9]rc[0-9]-[0-9]/ /' | \
    sed 's/ [0-9].[0-9][0-9][0-9].[0-9]-[0-9]/ /' | \
    sed 's/ [0-9].[0-9][0-9].[0-9][0-9][0-9]-[0-9]/ /' | \
    sed 's/ [0-9][0-9][0-9]-[0-9]/ /' | \
    sed 's/ [0-9][0-9][0-9][0-9][a-z]-[0-9]/ /' | \
    sed 's/ [0-9].[0-9][0-9]-[0-9]/ /' | \
    sed 's/ [0-9][0-9].[0-9].[0-9]-[0-9]/ /' | \
    sed 's/ [0-9].[0-9][0-9].[0-9]-[0-9]/ /' | \
    sed 's/ [0-9].[0-9][0-9].[0-9][0-9]-[0-9]/ /' | \
    sed 's/ [0-9].[0-9].[0-9]-[0-9]/ /' | \
    sed 's/ [0-9].[0-9][0-9].[0-9][0-9][0-9]-[0-9]/ /' | \
    sed 's/ [0-9].[0-9].[0-9][0-9]-[0-9]/ /' | \
    sed 's/ [0-9].[0-9]-[0-9]/ /' | \
    sed 's/ [0-9].[0-9]/ /' | \
    sed 's/ .[0-9].[0-9]-[0-9]/ /' | \
    sed 's/ .[0-9][0-9].[0-9][0-9][0-9]-[0-9]/ /' | \
    sed 's/ .[0-9][0-9].[0-9]-[0-9]/ /' > ~/archlinux-pacman-pkglist-$Y.txt
  }

  function packageinstall() {
    case $2 in
      single|allein)
        for paket in $(cat $1); do
          echo "\n\n" $paket;
          sudo apt-get -y install $paket;
          done
          ;;
      all|alles)
        sudo apt-get -y install $(cat $1);
        ;;
      *)
      echo "Fehler: $2 ist ungültig"
      ;;
    esac
  }

  # todo: merge with zsh-plugin -> archlinux.plugin.zsh
  function apt-date(){
    #sudo aptitude update && sudo aptitude safe-upgrade && sudo aptitude autoclean && sudo aptitude clean && sudo aptitude autoremove
    #sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get autoremove && sudo apt-get autoclean
    sudo pacman -Syu
  }

  function ins(){
    sudo pacman -S $1
    #sudo apt-get -y install $1
  }

  function build1(){
   ./configure  &&  fakeroot dpkg-buildpackage
  }

  function build2(){
   dh_make --createorig -s --email a.groetschel@inet-service.org
   dpkg-buildpackage -S -sa -rfakeroot
   sudo pbuilder create ../*.dsc
   sudo pbuilder build ../*.dsc
  }