
#!/bin/bash

BACKUP_DIR="$HOME/backup_sistem"
mkdir -p "$BACKUP_DIR"

cek_kapasitas() {
    local lokasi="$1"
    local kebutuhan="$2"

    local tersedia
    tersedia=$(df -Pk "$lokasi" | awk 'NR==2 {print $4}')

    if [ "$tersedia" -ge "$kebutuhan" ]; then
        return 0
    else
        return 1
    fi
}

backup_data() {
    echo ""
    read -rp "Masukkan lokasi folder yang ingin di-backup: " SUMBER

    if [ ! -d "$SUMBER" ]; then
        echo "[GAGAL] Folder sumber tidak ditemukan!"
        return
    fi

    SUMBER=$(realpath "$SUMBER")
    UKURAN=$(du -sk "$SUMBER" | awk '{print $1}')

    KEBUTUHAN=$((UKURAN + UKURAN / 10 + 51200))

    if ! cek_kapasitas "$BACKUP_DIR" "$KEBUTUHAN"; then
        echo "[GAGAL] Kapasitas penyimpanan tidak mencukupi!"
        return
    fi

    NAMA="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    FILE_SEMENTARA="$BACKUP_DIR/$NAMA.tmp"

    echo "Sedang membuat backup..."

    if tar -czf "$FILE_SEMENTARA" -C "$(dirname "$SUMBER")" "$(basename "$SUMBER")"; then
        if tar -tzf "$FILE_SEMENTARA" > /dev/null; then
            mv "$FILE_SEMENTARA" "$BACKUP_DIR/$NAMA"
            echo "[BERHASIL] Backup tersimpan di:"
            echo "$BACKUP_DIR/$NAMA"
        else
            rm -f "$FILE_SEMENTARA"
            echo "[GAGAL] File backup tidak valid!"
        fi
    else
        rm -f "$FILE_SEMENTARA"
        echo "[GAGAL] Proses backup gagal!"
    fi
}

restore_data() {
    echo ""
    read -rp "Masukkan lokasi file backup: " FILE_BACKUP

    if [ ! -f "$FILE_BACKUP" ]; then
        echo "[GAGAL] File backup tidak ditemukan!"
        return
    fi

    if ! tar -tzf "$FILE_BACKUP" > /dev/null 2>&1; then
        echo "[GAGAL] File backup rusak atau tidak valid!"
        return
    fi

    if tar -tzf "$FILE_BACKUP" | awk '
        /^\// {exit 1}
        {
            n=split($0, bagian, "/")
            for (i=1; i<=n; i++) {
                if (bagian[i]=="..") exit 1
            }
        }
        END {if (NR==0) exit 1}
    '; then
        :
    else
        echo "[GAGAL] Isi arsip tidak aman atau kosong!"
        return
    fi

    read -rp "Masukkan lokasi tujuan restore: " TUJUAN
    mkdir -p "$TUJUAN"

    TUJUAN=$(realpath "$TUJUAN")

    UKURAN=$(tar -tvzf "$FILE_BACKUP" | awk '
        {
            total += $3
        }
        END {
            print int(total / 1024)
        }
    ')

    KEBUTUHAN=$((UKURAN + UKURAN / 10 + 51200))

    if ! cek_kapasitas "$TUJUAN" "$KEBUTUHAN"; then
        echo "[GAGAL] Kapasitas penyimpanan tidak mencukupi!"
        return
    fi

    FOLDER_RESTORE="$TUJUAN/restore_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$FOLDER_RESTORE"

    echo "Sedang melakukan restore..."

    if tar -xzf "$FILE_BACKUP" -C "$FOLDER_RESTORE" --no-same-owner; then
        if [ -n "$(ls -A "$FOLDER_RESTORE")" ]; then
            echo "[BERHASIL] Data berhasil di-restore!"
            echo "Lokasi hasil restore:"
            echo "$FOLDER_RESTORE"
        else
            echo "[GAGAL] Folder hasil restore kosong!"
        fi
    else
        echo "[GAGAL] Proses restore gagal!"
    fi
}

while true
do

    echo "       BACKUP & RESTORE SYSTEM"

    echo "1. Backup Data"
    echo "2. Restore Data"
    echo "3. Keluar"

    read -rp "Pilih menu (1-3): " PILIHAN

    case "$PILIHAN" in
        1) backup_data ;;
        2) restore_data ;;
        3)
            echo "Program selesai."
            exit 0
            ;;
        *)
            echo "Pilihan tidak valid!"
            ;;
    esac
done
