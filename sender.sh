title="**** EMAIL SENDER by kubilaycakmak****"

prompt="Pick an option:"
options=("set sender email" "set smtp(use just once)" "set destination emails" "set context", "prepare to send!")

echo "$title"
PS3="$prompt "
declare -a to=()
declare -a body=()
select opt in "${options[@]}" "Quit"; do
    case "$REPLY" in
    1 )
    echo "Please write root email"
    read rootEmail
    echo "Please write root email's password"
    read password
    from="$rootEmail"
    echo smtp.gmail.com:587 $rootEmail:$password > /etc/postfix/sasl_passwd
    echo "The root mail is $rootEmail";;
    
    2 ) echo "smtp set"
    smtpGmailsettings="smtp.gmail.com:587 $rootEmail:$password"
    echo $smtpGmailsettings > /etc/postfix/sasl_passwd
    postmap /etc/postfix/sasl_passwd
    mainSettingImport="
    relayhost=smtp.gmail.com:587
    \nsmtp_sasl_auth_enable=yes
    \nsmtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd
    \nsmtp_use_tls=yes
    \nsmtp_tls_security_level=encrypt
    \ntls_random_source=dev:/dev/urandom
    \nsmtp_sasl_security_options = noanonymous
    \nsmtp_always_send_ehlo = yes
    \nsmtp_sasl_mechanism_filter = plain
    "
    echo $mainSettingImport >> /etc/postfix/main.cf
    postfix stop
    postfix start
    echo "**********************"
    ;;
    
    3 ) echo "Checking emails"
    echo "**********************"
    while IFS=',' read -r lineEmails
    do
        echo "$lineEmails"
        to+=( "${lineEmails}" )
    done < emails.txt
    echo ${to[@]}
    echo "**********************"
    ;;
    4 ) echo "Checking context"
    echo "**********************"
    while IFS= read -r lineContext
    do
        echo "$lineContext"
        body+=("$lineContext\n")
    done < context.txt
    echo ${body[@]}
    echo "**********************"
    ;;
    5 ) echo "Configures"
    echo "Enter subject: "
    read subject
    echo "Subject: $subject" > subject.txt
    echo "${body[@]}" >> subject.txt
    echo | sendmail -f "${from}" -t "${to[@]}" < subject.txt
    
    echo "SENDING..."
    ;;
    
    $(( ${#options[@]}+1 )) ) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one.";continue;;
    esac

done

while opt=$(zenity --title="$title" --text="$prompt" --list \
                    --column="Options" "${options[@]}"); do
    case "$opt" in
    "${options[0]}" ) zenity --info --text="You picked $opt, option 1";;
    "${options[1]}" ) zenity --info --text="You picked $opt, option 1";;
    "${options[2]}" ) zenity --info --text="You picked $opt, option 2";;
    "${options[3]}" ) zenity --info --text="You picked $opt, option 3";;
    "${options[4]}" ) zenity --info --text="You picked $opt, option 4";;
    *) zenity --error --text="Invalid option. Try another one.";;
    esac
done
