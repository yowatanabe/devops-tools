#!/bin/bash

# 現在の曜日、時間、分、秒を取得
current_day=$(date +"%u")  # 1:月曜日, ..., 7:日曜日
current_time=$(date +"%H%M%S")  # 時間をHHMMSS形式で取得

# 各曜日の開始時刻と終了時刻を設定（フォーマット: HHMMSS）
case "$current_day" in
    1)
        # 月曜日の実行可能時間: 10:00:00〜18:00:00
        start_time="100000"
        end_time="180000"
        ;;
    2)
        # 火曜日の実行可能時間: 09:00:00〜17:00:00
        start_time="090000"
        end_time="170000"
        ;;
    3)
        # 水曜日の実行可能時間: 08:00:00〜16:00:00
        start_time="080000"
        end_time="160000"
        ;;
    4)
        # 木曜日の実行可能時間: 11:00:00〜19:00:00
        start_time="110000"
        end_time="190000"
        ;;
    5)
        # 金曜日の実行可能時間: 12:00:00〜20:00:00
        start_time="120000"
        end_time="200000"
        ;;
    6)
        # 土曜日の実行可能時間: 09:30:00〜14:30:00
        start_time="093000"
        end_time="143000"
        ;;
    7)
        # 日曜日の実行可能時間: 10:00:00〜15:00:00
        start_time="100000"
        end_time="150000"
        ;;
    *)
        echo "無効な曜日です。"
        exit 1
        ;;
esac

# 時間帯のチェック（開始時刻以上かつ終了時刻未満）
if [ "$current_time" -ge "$start_time" ] && [ "$current_time" -lt "$end_time" ]; then
    echo "コマンドを実行します。"
    # ここに実行したいコマンドを記述
    /path/to/your/command
else
    echo "現在は実行可能時間外のため、コマンドは実行されません。"
fi
