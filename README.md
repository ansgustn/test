# BookMark - AI 기반 스마트 E-Book 리더

AI 기술이 통합된 지능형 전자책 리더 앱입니다.

## 주요 기능

- 📚 EPUB/PDF 파일 지원
- 🤖 AI 요약 & Q&A (Gemini API)
- 📝 스마트 노트 관리 (자동 태그 생성)
- 📊 독서 통계 & 진행률
- 🎨 커스터마이징 가능한 뷰어 설정
- ⭐ AI 기반 책 추천

## 시작하기

### 1. API Key 설정

이 앱은 Google Gemini API를 사용합니다.

1. [Google AI Studio](https://aistudio.google.com/app/apikey)에서 API Key를 발급받으세요.
2. `test/Services/Config.swift.example` 파일을 복사하여 `Config.swift`로 이름을 변경합니다:
   ```bash
   cp test/Services/Config.swift.example test/Services/Config.swift
   ```
3. `Config.swift` 파일을 열고 `YOUR_GEMINI_API_KEY_HERE`를 발급받은 API Key로 교체합니다.

### 2. 프로젝트 실행

1. Xcode에서 `test.xcodeproj` 파일을 엽니다.
2. 시뮬레이터 또는 실제 기기를 선택합니다.
3. Cmd+R을 눌러 실행합니다.

### 3. 샘플 책 사용

앱 실행 시 자동으로 샘플 EPUB 책이 Documents 폴더에 생성됩니다.

## 보안 주의사항

⚠️ **중요**: API Key는 절대 Git에 커밋하지 마세요!

- `Config.swift` 파일은 `.gitignore`에 추가되어 있습니다.
- `Config.swift.example` 파일만 커밋되며, 실제 API Key는 포함되지 않습니다.

## 기술 스택

- SwiftUI
- CoreData
- Google Gemini API
- PDFKit
- Swift Charts

## 라이선스

개인 프로젝트
