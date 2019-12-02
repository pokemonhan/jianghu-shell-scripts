ssh -l root 172.19.0.1 \
                  -o PasswordAuthentication=no    \
                  -o StrictHostKeyChecking=no     \
                -o UserKnownHostsFile=/dev/null \
                 -p 2226                         \
                 -i /var/jenkins_workspace/harrisdock/workspace7/insecure_id_rsa    \
                "cd /var/www/jianghu_entertain;\
                php -v;\
                COMPOSER_IN_SYNC=\$(composer outdated);\
                echo \"composer status are \$COMPOSER_IN_SYNC\";\
               "