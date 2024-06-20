if [ $FLAVOR = "Sponge" ]; then
    cd /home/container/sponge
    java -Xms128M -XX:MaxRAMPercentage=95.0 -jar $SERVER_JARFILE
elif [ $FLAVOR = "Paper" ]; then
    cd /home/container/paper
    java -Xms128M -XX:MaxRAMPercentage=95.0 -Dterminal.jline=false -Dterminal.ansi=true -jar $SERVER_JARFILE
elif [ $FLAVOR = "Forge" ]; then
    cd /home/container/forge
    java -Xms128M -XX:MaxRAMPercentage=95.0 -Dterminal.jline=false -Dterminal.ansi=true $( [[  ! -f unix_args.txt ]] && printf %s "-jar $SERVER_JARFILE" || printf %s "@unix_args.txt" )
elif [ $FLAVOR = "Bungeecord" ]; then
    cd /home/container/bungeecord
    java -Xms128M -XX:MaxRAMPercentage=95.0 -jar $SERVER_JARFILE
elif [ $FLAVOR = "Java" ]; then
    cd /home/container/java
    java -Xms128M -XX:MaxRAMPercentage=95.0 -jar $SERVER_JARFILE
elif [ $FLAVOR = "Bedrock" ]; then
    cd /home/container/bedrock
    ./bedrock_server
else
    echo "Unknown flavor"
    exit 0
fi
