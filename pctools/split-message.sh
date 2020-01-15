#!/bin/sh
# cd /e/projects/jianghu_entertain;
# folder="/e/test"
# for file in $folder/*; do
#   echo "${file##*/} and full is $file"
# done

STRING='[2020-01-10 15:45:46] test-harris.INFO: Inputs are {
    "name": "ling009",
    "email": "ling009@gmail.com",
    "password": "123qwe",
    "is_test": "0",
    "group_id": "36",
    "XDEBUG_SESSION_START": "PHPSTORM"
}  
[2020-01-10 15:45:46] test-harris.INFO: Headers are {
    "connection": [
        "keep-alive"
    ],
    "content-length": [
        "617"
    ],
    "accept-encoding": [
        "gzip, deflate"
    ],
    "host": [
        "api.jianghu.me"
    ],
    "postman-token": [
        "f5874a38-f48d-40e2-823d-607c7e2bb9f6"
    ],
    "cache-control": [
        "no-cache"
    ],
    "user-agent": [
        "PostmanRuntime\/7.21.0"
    ],
    "content-type": [
        "multipart\/form-data; boundary=--------------------------131993241120599330916199"
    ],
    "accept": [
        "application\/json"
    ],
    "authorization": [
        "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9hcGkuamlhbmdodS5tZVwvXC9tZXJjaGFudC1hcGlcL2xvZ2luIiwiaWF0IjoxNTc4NjQxNDAxLCJleHAiOjE1Nzg2NDUwMDEsIm5iZiI6MTU3ODY0MTQwMSwianRpIjoiYkVvTzJhRUFNc0tCREF1UiIsInN1YiI6MSwicHJ2IjoiZWUxOWIwMDY4Nzk1OGJlYjc5ZTY4NDA0MWU2ODkwM2I4YjY5ODg4YiJ9.LOJpXvDr-m681lph2RE79kInP0RXepj6s7vJ0XjH1NU"
    ]
}  
[2020-01-10 16:07:44] test-harris.INFO: Inputs are {
    "name": "ling009",
    "email": "ling009@gmail.com",
    "password": "123qwe",
    "is_test": "0",
    "group_id": "36",
    "XDEBUG_SESSION_START": "PHPSTORM"
}  
[2020-01-10 16:07:44] test-harris.INFO: Headers are {
    "connection": [
        "keep-alive"
    ],
    "content-length": [
        "617"
    ],
    "accept-encoding": [
        "gzip, deflate"
    ],
    "host": [
        "api.jianghu.me"
    ],
    "postman-token": [
        "c221f155-7cc6-45ed-a813-6616086c0b82"
    ],
    "cache-control": [
        "no-cache"
    ],
    "user-agent": [
        "PostmanRuntime\/7.21.0"
    ],
    "content-type": [
        "multipart\/form-data; boundary=--------------------------516497113272899151655946"
    ],
    "accept": [
        "application\/json"
    ],
    "authorization": [
        "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9hcGkuamlhbmdodS5tZVwvXC9tZXJjaGFudC1hcGlcL2xvZ2luIiwiaWF0IjoxNTc4NjQxNDAxLCJleHAiOjE1Nzg2NDUwMDEsIm5iZiI6MTU3ODY0MTQwMSwianRpIjoiYkVvTzJhRUFNc0tCREF1UiIsInN1YiI6MSwicHJ2IjoiZWUxOWIwMDY4Nzk1OGJlYjc5ZTY4NDA0MWU2ODkwM2I4YjY5ODg4YiJ9.LOJpXvDr-m681lph2RE79kInP0RXepj6s7vJ0XjH1NU"
    ]
}  
'
STRLENGTH=$(echo -n $STRING | wc -m)
echo "length is $STRLENGTH"
for (( c=1; c<=$STRLENGTH; c+=500 ))
do  
   var="${STRING:$c:500}"
   echo "now  is ${var}\n"
done
# awk '{for(i=1;i<length;i+=500) echo substr($toCommitDir,i,500)}'
echo Press Enter...
read
