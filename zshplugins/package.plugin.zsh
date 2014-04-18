
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

  function build1(){
   ./configure  &&  fakeroot dpkg-buildpackage
  }

  function build2(){
   dh_make --createorig -s --email $1
   dpkg-buildpackage -S -sa -rfakeroot
   sudo pbuilder create ../*.dsc
   sudo pbuilder build ../*.dsc
  }