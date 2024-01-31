#!/bin/bash

# Mostrar el uso de disco en / y /home
echo "Uso de disco en /:"
df -h /

echo "Tamaño de carpetas en /:"
sudo du -sch /* | sort -hr

echo "Tamaño de carpetas en /home:"
sudo du -sch /home/* | sort -hr


function obtener_tamanos() {
    local path=$1
    (cd "$path" && du -sch -- * | grep -v -e "cur" -e "new" -e "tmp" -e "mailboxes" -e "storage" | sort -hr)
}

function obtener_tamanos2() {
    local path=$1

    # Se cambia du -sch * por du -sch .[!.]* * 
    # Para abarcar carpetas y archivos ocultos
    
    (cd "$path" && du -sch -- .[!.]* * | grep -v -e "cur" -e "new" -e "tmp" -e "mailboxes" -e "storage" | sort -hr)
}

# Revisar usuarios
for user in /home/*
do
    if [ -d "$user" ]; then
        user=$(basename "$user")
        echo "Usuario: $user"
        echo "----------------------------------------"
        echo "Carpetas en /home/$user:"
# Revisa carpetas en home
        du -sch --exclude=clamav --exclude=cPanelInstall --exclude=latest --exclude=virtualfs /home/$user/* 2>/dev/null | grep -v "/home/$user/clamav" | grep -v "/home/$user/cPanelInstall" | grep -v "/home/$user/latest" | grep -v "/home/$user/virtualfs" | sort -hr
        echo

        if [ -d /home/$user/public_html ]; then
            echo "Carpetas en /home/$user/public_html:"
            # Se incluyen archivos y carpetas ocultas
            obtener_tamanos2 "/home/$user/public_html"
            echo
        fi

        if [ -d /home/$user/mail ]; then
            echo "Carpetas en /home/$user/mail:"
# Revisa carpetas en mail, ignora carpetas ocultas, carpeta new, tmp, mailboxes y storage
            find /home/$user/mail -maxdepth 1 -mindepth 1 -type d -not -name ".*" -not -name "cur" -not -name "new" -not -name "tmp" -not -name "mailboxes" -not -name "storage" 2>/dev/null -exec sh -c '
                for folder; do
#Escanea cuentas de correo
                    echo "Cuentas de correo en $folder"
                    (cd "$folder" && du -sch -- * | grep -v -e "cur" -e "new" -e "tmp" -e "mailboxes" -e "storage" | sort -hr)
                done
            ' _ {} +
            echo
        fi
    fi
done
