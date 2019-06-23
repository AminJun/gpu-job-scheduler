message="Gholamali" 
post=1
if [ "${post}" == "1" ] ; then 
	curl -X POST https://textbelt.com/text \
	       --data-urlencode phone='2025945672' \
	       --data-urlencode message="${message}" \
	       -d key="ccde440c14a26bcce8344420d9ac14d625070283jRvxpQNv6nzcXPSmlUHxvgKF6"
fi
#curl -X POST https://textbelt.com/text \
#       --data-urlencode phone='3017899787' \
#       --data-urlencode message='Dude you have a free GPU at GholamAli' \
#       -d key="ccde440c14a26bcce8344420d9ac14d625070283jRvxpQNv6nzcXPSmlUHxvgKF6"
