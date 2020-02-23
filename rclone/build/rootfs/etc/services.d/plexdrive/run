#!/usr/bin/with-contenv sh

source /etc/colors.sh

PREFFIX="[services.d] [plexdrive]-$(s6-basename ${0}):"

echo -e "${PREFFIX} ${Green}starting Plexdrive $(date +%Y.%m.%d-%T)${Color_Off}"

/bin/plexdrive mount --cache-file="/shared/caches/plexdrive.bolt" -v 2 -o allow_other /plexdrive