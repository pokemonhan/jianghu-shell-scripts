ssh -l root 172.19.0.1 \
                  -o PasswordAuthentication=no    \
                  -o StrictHostKeyChecking=no     \
                -o UserKnownHostsFile=/dev/null \
                 -p 2225                         \
                 -i /var/jenkins_workspace/harrisdock/workspace7/insecure_id_rsa    \
                "cd /var/www/jianghu_entertain;\
                counter=0
                while [ \$counter -lt 20 ]
                do
                  message=\"\$(git log -1 --skip \$counter --pretty=%B)\"
                  if [[ \${message} == *\"Merge\"* ]]; then
                   echo here is in merge \"\${message}\";
                    ((counter++))
                   else
                   echo here is normal msg \"\${message}\";
                      break
                   fi
                  echo count is \$counter and message is \$message
                done
"
