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

# テーブルリストの確認
TABLES_FILE="$PROJECT_DIR/tables.txt"
if [ ! -f "$TABLES_FILE" ]; then
    echo "Error: テーブルリストファイルが見つかりません: $TABLES_FILE"
    exit 1
fi

# ダンプフォルダの作成 (タイムスタンプ付き)
DUMP_FOLDER="$PROJECT_DIR/dumps/Dump_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$DUMP_FOLDER"

# ログファイル (固定の logs/ ディレクトリに保存)
LOG_FILE="./dump.log"

# テーブルごとのダンプ処理
echo "ダンプを開始します (フォルダ: $DUMP_FOLDER)..." | tee -a "$LOG_FILE"
while IFS= read -r TABLE; do
    if [ -n "$TABLE" ]; then
        OUTPUT_FILE="$DUMP_FOLDER/${TABLE}.sql"
        echo "テーブル '$TABLE' のダンプを開始します..." | tee -a "$LOG_FILE"
        mysqldump -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" -P "$DB_PORT" "$DB_NAME" "$TABLE" > "$OUTPUT_FILE" 2>> "$LOG_FILE"
        if [ $? -eq 0 ]; then
            echo "$(date): テーブル '$TABLE' のダンプに成功しました: $OUTPUT_FILE" | tee -a "$LOG_FILE"
        else
            echo "$(date): テーブル '$TABLE' のダンプに失敗しました" | tee -a "$LOG_FILE"
        fi
    fi
done < "$TABLES_FILE"

echo "すべてのテーブルのダンプが完了しました。" | tee -a "$LOG_FILE"
