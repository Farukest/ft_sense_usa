echo 'START...'

echo 'HERŞEY BAŞTAN KURULUYOR SAKİN OL :) ...'

# ftfolder=/home/ft
# if [ -d "$ftfolder" ]; then
	# echo 'FT KLASORU SILINIYOR ...'
	# rm -rf /home/ft/
# fi

# ftfolder1=/home/ft_sensecap
# if [ -d "$ftfolder1" ]; then
	# echo 'FT KLON KLASORU SILINIYOR ...'
	# rm -rf /home/ft_sensecap/
# fi

# cd /home/ && git clone https://github.com/Farukest/ft_sensecap.git && mv ft_sensecap ft

chmod 777 /home/ft/hs_ft_pf_conf.json
sed -i 's/replace_collector_address/'"${collector_address}"'/g' /home/ft/hs_ft_pf_conf.json

chmod 777 /home/ft/ftmiddle_configs/conf1.json
sed -i 's/"replace_listen_port_address"/'${listen_port}'/g' /home/ft/ftmiddle_configs/conf1.json

chmod 777 /home/ft/ftmiddle_configs/conf1.json
sed -i 's/"replace_gateway_id"/"'${gateway_ID}'"/g' /home/ft/ftmiddle_configs/conf1.json

sleep 1

chmod 700 /home/ft/first.sh
cd /home/ft/ && ./first.sh


i=0
while [ $i -ne 4 ]
do
		i=$(($i+1))
		
		FILE=/home/ft/hs_ft_pf_$i/Makefile
		if [ -e "$FILE" ]; then
			echo "Makefile exist so may compiled c and obj.. check and remove them.."
			
			# Check pktfwd exist
			PKTFWD=/home/ft/hs_ft_pf_$i/packet_forwarder/lora_pkt_fwd$i
			if [ -e "$PKTFWD" ]; then
				echo "PKTFWD REMOVED.."
				rm -rf /home/ft/hs_ft_pf_$i/packet_forwarder/lora_pkt_fwd$i
			fi 

			# check obj .o exist
			PKTFWDOBJ=/home/hs_ft_pf_$i/packet_forwarder/obj/lora_pkt_fwd$i.o
			if [ -e "$PKTFWDOBJ" ]; then
				echo "PKTFWD .o REMOVED.."
				rm -rf /home/hs_ft_pf_$i/packet_forwarder/obj/lora_pkt_fwd$i.o
			fi 
						
			echo "Making new PKTFWD files and the OBJ .o files.."
			# Create new pktfwd and the obj .o					
			cd /home/ft/hs_ft_pf_$i/ && make -f Makefile
			echo "Making files success.."
			
			
			echo "Maked files moving and keeping and transferring.."
			# Move pktfwd to to tmp and then remove folders and again move pktfwd to folder
			mv /home/ft/hs_ft_pf_$i/packet_forwarder/lora_pkt_fwd$i /tmp/
			rm -rf /home/ft/hs_ft_pf_$i
			mkdir -p /home/ft/hs_ft_pf_$i/packet_forwarder/
			mv /tmp/lora_pkt_fwd$i /home/ft/hs_ft_pf_$i/packet_forwarder/  
			echo "Transferring success.."
		fi       
		
done

echo 'Jobs adding to cron..'
cd /home/ft/ && ./addcron.sh

default_docker=$(balena ps -a|grep pktfwd|awk -F" " '{print $NF}')
balena stop $default_docker

mount -o rw,remount /home/ft/logs/

echo 'SUCCESS THAT IS ALL..'

while true; do sleep 1; done