<?php
// 未定義変数の使用（Warning 発生）
echo $undefined_variable;

// 明示的なエラー
trigger_error("手動エラー: テスト中", E_USER_ERROR);
