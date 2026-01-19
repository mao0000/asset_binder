# Asset-Binder

Asset-Binderは、会社の資産(Asset)である車両の情報を一元管理し、可視化するためのWebアプリケーションです。

## 概要

日々の車両情報を登録し、現在の車両状況を把握することができます。

## 主な機能

*   **ユーザー認証機能**: Deviseを使用したユーザー登録、ログイン、ログアウト機能。外部アクセスを遮断。
*   **車両管理機能**: 車両の登録、編集、削除、絞り込み検索（所属営業所、車両番号）。
*   **期限管理機能**: 車検証の満了日を自動計算、期限前にアラート表示、車検実施日の登録、絞り込み検索（所属営業所、車両番号）。
*   **給油カード管理機能**: 給油カードの登録、編集、削除、絞り込み検索（所属営業所、管理番号、ステータス、紐づく車両番号）。車両情報との紐付け。発行、受領、返却の履歴記録。
*   **給油記録管理機能**: 給油記録の登録、CSVデータインポート、編集、削除、絞り込み検索（給油月、所属営業所、車両番号）。
*   **レポート機能**: 登録されている車両・給油カード・給油記録のデータをもとに集計、分析。
*   **ダッシュボード**: 車検期限のアラート表示や給油カードの受領処理タスクを表示。各機能の新規登録ボタン、当月給油総額、登録車両数を表示。
*   **入力補助機能**: ActiveHashを使って入力欄をプルダウン選択。
*   **レスポンシブデザイン**: Tailwind CSSを採用。

## 使用技術

*   **バックエンド**: Ruby 3.2.0, Ruby on Rails 7.1.6
*   **フロントエンド**: Hotwire (Turbo, Stimulus), Tailwind CSS, Chart.js(Chart.jsを利用したグラフは現在エラーのため非表示)
*   **データベース**:
    *   開発/テスト: MySQL
    *   本番: PostgreSQL
*   **インフラ**: Render
*   **ビルドツール**: esbuild

## ER図

```mermaid
erDiagram
    users ||--o{ vehicles : manages
    vehicles ||--o{ cards : has
    vehicles ||--o{ inspections : has
    cards ||--o{ fuels : used_at

    users {
        bigint id PK
        string email
        string name
        integer role
        integer branch_id
    }

    vehicles {
        bigint id PK
        string v_location "地名"
        string v_code "分類番号"
        string v_kana "ひらがな"
        string v_serial "一連指定番号"
        integer office_id
        integer status_id
        string obe_number "車載器管理番号"
        date first_registration_date "初度年月"
        string usage "用途"
        string usage_type "自家用・事業用の別"
        integer gross_weight "車両総重量"
        string vehicle_type "自動車の種別"
        integer inspection_cycle_years "車検周期"
        date inspection_expiration_date "車検満了日"
        references user_id FK
    }

    cards {
        bigint id PK
        string internal_id "管理番号"
        string card_number "カード番号"
        integer issue_type
        integer status
        datetime received_on "受領日"
        datetime returned_on "返却日"
        text remarks "備考"
        references vehicle_id FK
    }

    fuels {
        bigint id PK
        datetime filled_at "給油日時"
        integer amount "金額"
        float volume "給油量"
        integer unit_price "単価"
        string store_name "給油所名"
        references card_id FK
    }

    inspections {
        bigint id PK
        date conducted_on "実施日"
        integer inspection_type_id
        text memo "メモ"
        references vehicle_id FK
    }
```

## 画面遷移図

```mermaid
graph TD
    User((ユーザー)) --> Login[ログイン画面]
    Login --> Dashboard[ダッシュボード]
    Dashboard -.-> |ログアウト| Login

    Dashboard --> Vehicles[車両管理]
    Dashboard --> Inspections[車検スケジュール管理]
    Dashboard --> Cards[給油カード管理]
    Dashboard --> Fuels[給油記録管理]
    Dashboard --> Report[レポート機能]

    Vehicles --> VehicleList[車両一覧]
    VehicleList --> VehicleNew[車両登録]
    VehicleList --> VehicleShow[車両詳細]
    VehicleShow --> VehicleEdit[車両編集]
    VehicleShow --> InspectionNew[車検登録]

    Inspections --> VehicleShow

    Cards --> CardList[カード一覧]
    CardList --> CardNew[カード登録]
    CardList --> CardShow[カード詳細]
    CardShow --> CardEdit[カード編集]

    Fuels --> FuelList[給油記録一覧]
    FuelList --> FuelNew[給油記録登録]
    FuelList --> FuelImport[CSVインポート]
    FuelList --> FuelEdit[給油記録編集]
```
