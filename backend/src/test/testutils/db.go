package testutils

import (
	"database/sql"
	"testing"
	"time"

	_ "github.com/lib/pq"
)

// setupTestDB テスト用DB接続を設定
func SetupTestDB(t *testing.T) *sql.DB {
	dsn := "host=localhost port=15434 user=sampleuser password=samplepass dbname=sampledb_test sslmode=disable"
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		t.Fatalf("DB接続失敗: %v", err)
	}
	// DB起動待ち
	for i := 0; i < 10; i++ {
		if err := db.Ping(); err == nil {
			return db
		}
		time.Sleep(1 * time.Second)
	}
	t.Fatal("DB接続がタイムアウトしました")
	return nil
}