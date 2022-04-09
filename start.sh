#!/bin/zsh

if grep -i "resource-pack=https" server.properties; then
    url=$(grep -i "resource-pack=https" server.properties | sed "s/resource-pack=https\\\:/https:/")
    sha1sum=$(curl "$url" | sha1sum - | awk '{print $1}')
    sed --in-place=".bak" -E "s/resource-pack-sha1=[0-9a-f]*/resource-pack-sha1=$sha1sum/g" server.properties
fi

/usr/lib/jvm/jre-18/bin/java -Xmx4096M -Xms1024M -Djava.net.preferIPv4Stack=true -jar server.jar nogui

echo "Server shut down."

