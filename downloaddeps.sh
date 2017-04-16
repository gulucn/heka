#!/bin/sh

path=`dirname $(readlink -f $0)`

GIT_EXECUTABLE="git"


eval_cmd () {
	cmd="$1"
	echo "$cmd"
	eval "$cmd"
	ret=$?
	if [ $ret -ne 0 ];then
		echo "exec result: $ret"
		exit 1
	fi
}

git_clone() {
	url="$1"
	name="${url##*/}"
	tmpname="${name}.bak"
	if [ -e "$name" ];then
		echo "$name is exists,skip to clone"
		return
	fi
	rm -rf "$tmpname"
	tag="$2"
        eval_cmd "git clone $url ${tmpname}"
	eval_cmd "cd ${tmpname}"
	eval_cmd "git checkout $tag"
	eval_cmd "cd .."
	eval_cmd "mv ${tmpname} ${name}"
}

mkdir -p "$path/externals" && cd "$path/externals"

git_clone https://github.com/mozilla-services/lua_sandbox 97331863d3e05d25131b786e3e9199e805b9b4ba
git_clone https://github.com/rafrombrc/gomock c922279faf77f29ce5781e96eb0711837fcb477c
git_clone https://github.com/rafrombrc/whisper-go 89e9ba3b5c6a10d8ac43bd1a25371f3e6118c37f
git_clone https://github.com/rafrombrc/go-notify e3ddb616eea90d4e87dff8513c251ff514678406
git_clone https://github.com/bbangert/toml a2063ce2e5cf10e54ab24075840593d60f59b611
git_clone https://github.com/streadway/amqp 7d6d1802c7710be39564a287f860360c6328f956
git_clone https://github.com/rafrombrc/gospec 2e46585948f47047b0c217d00fa24bbc4e370e6b
git_clone https://github.com/crankycoder/xmlpath 670b185b686fd11aa115291fb2f6dc3ed7ebb488
git_clone https://github.com/thoj/go-ircevent 90dc7f966b95d133f1c65531c6959b52effd5e40
git_clone https://github.com/cactus/gostrftime d329f83c5ce9c416f8983f0a0044734db54ee24d
git_clone https://github.com/golang/snappy 723cc1e459b8eea2dea4583200fd60757d40097a
git_clone https://github.com/eapache/go-resiliency v1.0.0
git_clone https://github.com/eapache/queue v1.0.2
git_clone https://github.com/davecgh/go-spew 2df174808ee097f90d259e432cc04442cf60be21
git_clone https://github.com/fsouza/go-dockerclient 175e1df973274f04e9b459a62cffc49808f1a649
git_clone https://github.com/AdRoll/goamz e0af8b0b22517e9fb1d6a4438fa8269c3e834d2d
git_clone https://github.com/feyeleanor/raw 724aedf6e1a5d8971aafec384b6bde3d5608fba4
git_clone https://github.com/feyeleanor/slices bb44bb2e4817fe71ba7082d351fd582e7d40e3ea
git_clone https://github.com/feyeleanor/sets 6c54cb57ea406ff6354256a4847e37298194478f
git_clone https://github.com/crankycoder/g2s 2594f7a035ed881bb10618bc5dc4440ef35c6a29
git_clone https://github.com/getsentry/raven-go 0cc1491d9d27b258a9b4f0238908cb0d51bd6c9b
git_clone https://github.com/pborman/uuid ca53cad383cad2479bbba7f7a1a05797ec1386e4
git_clone https://github.com/gogo/protobuf 7d21ffbc76b992157ec7057b69a1529735fbab21


