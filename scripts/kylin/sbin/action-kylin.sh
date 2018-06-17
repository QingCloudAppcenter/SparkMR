#!/bin/bash  
source /etc/profile    
source /opt/kap-plus/sbin/kylinutil.sh   

#vim /home/kylin/.profile
#export KYLIN_HOME=/opt/kap-plus
#export PATH=/opt/hadoop/bin:/opt/hive/bin:/opt/sqoop/bin:/opt/spark/bin:/usr/jdk/bin:${PATH}
#export SPARK_HOME=$KYLIN_HOME/spark
#export KYLINAPP_LOG=/opt/qingcloud/sbin/kylinapp.log

echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - test1 - user=`whoami`,SPARK_HOME=$SPARK_HOME " 1>>$KYLINAPP_LOG  2>&1
export SPARK_HOME=$KYLIN_HOME/spark
echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - test2 - user=`whoami`,export SPARK_HOME,SPARK_HOME=$SPARK_HOME " 1>>$KYLINAPP_LOG  2>&1

 
action=$1  
echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - user=`whoami`,Action=$action Start ...." 1>>$KYLINAPP_LOG  2>&1
 
touch /home/kylin/ignore_healthcheck
echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - add /home/kylin/ignore_healthcheck to ignore appcenter healthcheck. " 1>>$KYLINAPP_LOG  2>&1 	 

if [ "$action"x == "start"x ]
then 
	sudo /opt/hadoop/bin/hadoop fs -test -e /tmp
	if [ $? -ne 0 ]
    then  
    	sudo /opt/hadoop/bin/hadoop fs -mkdir /tmp
    	sudo /opt/hadoop/bin/hadoop fs -chmod -R 777 /tmp 
    	echo "`date '+%Y-%m-%d %H:%M:%S'` - kylinutil.sh - INFO - user=`whoami`,chmod -R 777 /tmp" 1>>$KYLINAPP_LOG  2>&1
	fi
	
	/opt/kap-plus/sbin/j-start-kylin.sh   
	if [  $? -ne 0 ] 
	then 
		echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - Error -j-start-kylin.sh failed,Start Kylin Service failed." 1>>$KYLINAPP_LOG  2>&1	
		rm /home/kylin/ignore_healthcheck
		echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - rm /home/kylin/ignore_healthcheck to recovery appcenter healthcheck. " 1>>$KYLINAPP_LOG  2>&1 
		
		if [  -f "/opt/kap-plus/sbin/neverStartFlag" ]
		then 
			rm /opt/kap-plus/sbin/neverStartFlag
			echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - After cluster init, remove the neverStartFlag when start service." 1>>$KYLINAPP_LOG  2>&1
		fi
			 
		echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - Action=$action End ...." 1>>$KYLINAPP_LOG  2>&1		
		exit 1  
	fi
	
	enable_kylin=$(curl -s http://metadata/self/env/enable_kylin)
	echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - enable_kylin=$enable_kylin" 1>>$KYLINAPP_LOG  2>&1
	
	if [ "$enable_kylin"x == "true"x ]
	then
		if [ ! -f "/opt/kap-plus/sbin/hdfsfolder_created" ]
		then 
			$(DealWithHDFS4Kylin) 
		fi
		
		if [ ! -f "/opt/kap-plus/sbin/sample_loaded" ]
		then 
			$(loadSampleData4Kylin) 
		fi 
	fi 
	
	if [  -f "/opt/kap-plus/sbin/neverStartFlag" ]
	then 
		rm /opt/kap-plus/sbin/neverStartFlag
		echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - After cluster init, remove the neverStartFlag when start service." 1>>$KYLINAPP_LOG  2>&1
	fi  
	
	
fi

if [ "$action"x == "stop"x ]
then 	
	/opt/kap-plus/sbin/stop-kylin.sh
    echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - Kylin Service already Stopped." 1>>$KYLINAPP_LOG  2>&1  
fi

if [ "$action"x == "restart"x ]
then 
	pid=`ps ax | grep kylin | grep -v grep | grep -v 'su kylin' | grep -v 'bash' | grep 'Dkylin.hive.dependency' | awk '{print $1}'` 
	if [ "$pid"x == ""x ] && [ -f "/opt/kap-plus/sbin/neverStartFlag" ]
	then 
		if [ "$pid"x == ""x ] 
		then 
			echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - No running Kylin exits." 1>>$KYLINAPP_LOG  2>&1	
	    fi
	    
		if [  -f "/opt/kap-plus/sbin/neverStartFlag" ] 
		then 
			echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - found neverStartFlag." 1>>$KYLINAPP_LOG  2>&1	
	    fi
	
		rm /home/kylin/ignore_healthcheck
		echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - rm /home/kylin/ignore_healthcheck to recovery appcenter healthcheck. " 1>>$KYLINAPP_LOG  2>&1  
		echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - Action=$action End ...." 1>>$KYLINAPP_LOG  2>&1 		
		exit 0
	fi
	
	  
	echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - execute script:stop-kylin.sh." 1>>$KYLINAPP_LOG  2>&1  
	/opt/kap-plus/sbin/stop-kylin.sh   
	  
	echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - Stop kylin then start." 1>>$KYLINAPP_LOG  2>&1 
	
	echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - execute script:j-start-kylin.sh." 1>>$KYLINAPP_LOG  2>&1   
	/opt/kap-plus/sbin/j-start-kylin.sh  
	if [  $? -ne 0 ] 
	then 
		echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - Error - Start Kylin Service failed." 1>>$KYLINAPP_LOG  2>&1
		rm /home/kylin/ignore_healthcheck
		echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - rm /home/kylin/ignore_healthcheck to recovery appcenter healthcheck. " 1>>$KYLINAPP_LOG  2>&1
		echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - Action=$action End ...." 1>>$KYLINAPP_LOG  2>&1	 		
		exit 1  
	fi 
	
fi  



rm /home/kylin/ignore_healthcheck
echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - rm /home/kylin/ignore_healthcheck to recovery appcenter healthcheck. " 1>>$KYLINAPP_LOG  2>&1  

if [  -f "/opt/kap-plus/sbin/neverStartFlag" ]
then 
	rm /opt/kap-plus/sbin/neverStartFlag
	echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - After cluster init, remove the neverStartFlag when start service." 1>>$KYLINAPP_LOG  2>&1
fi

 
echo "`date '+%Y-%m-%d %H:%M:%S'` - action-kylin.sh - INFO - Action=$action End ...." 1>>$KYLINAPP_LOG  2>&1








