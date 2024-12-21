# スクリプトのディレクトリに基づくパス設定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 設定ファイルの読み込み
CONFIG_FILE="$PROJECT_DIR/../db_config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: DB接続情報ファイルが見つかりません: $CONFIG_FILE"
    exit 1
fi
source "$CONFIG_FILE"

# インポート対象のDumpフォルダの指定
DUMP_FOLDER="$PROJECT_DIR/dumps"
if [ ! -d "$DUMP_FOLDER" ]; then
    echo "Error: ダンプフォルダが見つかりません: $DUMP_FOLDER"
    exit 1
fi

# ログファイル (インポート処理の記録)
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/import.log"
mkdir -p "$LOG_DIR"

# ディレクトリの選択（ユーザーにどのフォルダをインポートするか選ばせる）
echo "以下のダンプフォルダが見つかりました:"
ls -d "$DUMP_FOLDER"/Dump_* | tee -a "$LOG_FILE"
echo -e "\nインポートするフォルダをフルパスで入力してください:"
read -r SELECTED_FOLDER

if [ ! -d "$SELECTED_FOLDER" ]; then
    echo "Error: 選択されたフォルダが存在しません: $SELECTED_FOLDER" | tee -a "$LOG_FILE"
    exit 1
fi

# インポート処理開始
echo "インポートを開始します (フォルダ: $SELECTED_FOLDER)..." | tee -a "$LOG_FILE"
for FILE in "$SELECTED_FOLDER"/*.sql; do
    if [ -f "$FILE" ]; then
        TABLE_NAME=$(basename "$FILE" .sql)
        echo "テーブル '$TABLE_NAME' をインポートしています: $FILE" | tee -a "$LOG_FILE"
        mysql -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" -P "$DB_PORT" "$DB_NAME" < "$FILE" 2>> "$LOG_FILE"
        if [ $? -eq 0 ]; then
            echo "$(date): テーブル '$TABLE_NAME' のインポートに成功しました。" | tee -a "$LOG_FILE"
        else
            echo "$(date): テーブル '$TABLE_NAME' のインポートに失敗しました。" | tee -a "$LOG_FILE"
        fi
    fi
done

echo "すべてのファイルのインポートが完了しました。" | tee -a "$LOG_FILE"