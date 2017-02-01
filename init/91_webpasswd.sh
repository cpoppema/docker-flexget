if [ -z "$WEBPASSWD" ];then
  flexget -c /config/config.yml web passwd "$WEBPASSWD"  
fi
