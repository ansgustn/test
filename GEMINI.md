# GEMINI.md

## Project Overview

This project, named **BookMark**, is a native iOS/macOS application for an intelligent E-Book reader. It is built using SwiftUI.

The core concept is to provide a personalized and enhanced reading experience by integrating AI-powered features. These features include:

*   **AI Book Recommendations:** Suggests new books based on the user's reading history and preferences.
*   **AI Summarization:** Provides summaries of chapters or entire books.
*   **AI Q&A:** Allows users to ask questions about the content they are reading.
*   **Reading Analytics:** Tracks reading habits and provides statistics.

The application will support both EPUB and PDF formats and will feature a customizable reading interface.

## Building and Running

This is a standard Xcode project. To build and run the application:

1.  Open the `test.xcodeproj` file in Xcode.
2.  Select a target simulator or a connected device.
3.  Click the "Run" button (or press `Cmd+R`).

As of the last analysis, the project is in a boilerplate state and will only display a "Hello, world!" message.

## Development Conventions

*   **Language:** Swift
*   **UI Framework:** SwiftUI
*   **Architecture:** The project is in its initial stages, so no specific architectural pattern (like MVVM or TCA) has been established yet. It follows the standard SwiftUI app structure.

## Key Files

*   `prd.md`: The Product Requirements Document, which outlines the vision, features, and user stories for the BookMark application.
*   `test/testApp.swift`: The main entry point of the SwiftUI application.
*   `test/ContentView.swift`: The main view of the application. Currently, it only displays a "Hello, world!" message.


##개요 

**BookMark**는 단순한 E-Book뷰어를 넘어, AI 기술을 접목하여 사용자에게 지능적이고 개인화된 독서 경험을 제공하는 swiftUI기반의 네이티브 ios/macOS 애플리케이션입니다.

### 핵심 가치 제안
- **문제**: 
- 문제 정의 정보 과부화: 사용자는 수많은 E-Book중 자신에게 맞는 책을 효율적으로 찾기 어렵다.
- 비효율적 지식 관리: 독서중 하이라이트 메모를 하더라도, 이를 체계적으로 분류하고 다시 활용하기 어렵다.
- 수동적 독서 경험: 기존앱은 콘텐츠를 보여줄 뿐, 사용자가 내용을 더 깊이 이해하거나 핵심을 파악하도록 돕는 능동적인 보조기능이 부족하다.

**해결책**:
- 개인화 : AI 추천을 통해 사용자가 좋아할 만한 책을 발견하는 성공률을 높입니다.
- 효율성 : AI 요약 및 지능형 노트 기능을 통해 사용자의 독서 및 학습 효율을 극대화 합니다.
- 만족도: 매끄러운 네이티브UI (SwiftUI)와 스마트한 기능을 통해 높은 사용자 만족도와 유지율을 달성합니다.

**대상 고객**
- 학생 및 연구자: 전공 서적이나 논문을 읽고, 핵심내용을 빠르게 파악하며 자료를 체계적으로 관리해야 하는 사용자
- 다독가: 한 달에 여러 권의 책을 읽으며, 자신의 독서 이력을 관리하고 새로운 책을 끊임없이 탐색하는 사용자
- 자기계발형 지식인: 비즈니스/IT 서적을 읽으며 지식을 습득하고, 핵심만 빠르게 요약하여 적용하려는 사용자

###사용자 스토리지

Epic 1: 핵심 독서 경험
As a user, I want to 열기 EPUB 및 PDF 파일을 열어서, so that I can 내 책을 읽을 수 있다.
As a user, I want to 폰트 크기, 줄 간격, 테마(라이트/다크 모드)를 설정하여, so that I can 가장 편안한 환경에서 독서에 집중할 수 있다.
As a user, I want to 텍스트에 하이라이트를 하고 메모를 추가하여, so that I can 중요한 부분을 나중에 다시 찾아볼 수 있다.
As a user, I want to 내 독서 위치와 하이라이트가 iPhone, iPad, Mac 간에 동기화되어, so that I can 기기를 바꿔도 이어서 독서할 수 있다.

Epic 2: AI 스마트 추천
As a user, I want to 내 독서 이력과 선호 장르를 기반으로 책을 추천받아, so that I can 내가 좋아할 만한 새로운 책을 쉽게 발견할 수 있다.
As a user, I want to 책이 추천된 이유("이 책의 이런 점을 좋아하셨네요")를 함께 보고, so that I can 추천을 신뢰하고 선택할 수 있다.

Epic 3: AI 독서 비서
As a user, I want to 버튼 하나로 현재 챕터나 책 전체의 핵심 요약을 보고, so that I can 내용을 빠르게 파악하거나 복습할 수 있다.
As a user, I want to 내 하이라이트와 메모가 AI에 의해 자동으로 주제별 태그가 지정되고 분류되어, so that I can 관련 내용을 모아서 볼 수 있다.
As a user, I want to 책을 읽다가 "이 인물은 누구지?"처럼 책 내용에 대해 질문하고, so that I can 맥락을 벗어나지 않고 궁금증을 바로 해결할 수 있다.

Epic 4: 독서 동기부여
As a user, I want to 나의 일간/주간 독서 시간과 읽은 페이지 통계를 보고, so that I can 나의 독서 습관을 파악하고 관리할 수 있다.
As a user, I want to '연속 독서 챌린지' 같은 목표를 설정하고 달성하며, so that I can 독서에 대한 동기를 부여받을 수 있다

##3. 기능 요구사항 (Functional Requirements)

3.1. 코어 E-Book 뷰어 (P0 - 필수)
F-3.1.1: SwiftUI 기반의 뷰어는 EPUB, PDF 포맷 렌더링을 지원해야 한다.
F-3.1.2: 뷰어 설정: 폰트 사이즈 조절, 폰트 종류 변경, 줄 간격 조절, 테마 변경(라이트, 다크, 세피아).
F-3.1.3: 텍스트 롱탭(Long-press) 시 하이라이트(3가지 색상) 및 메모 추가 기능.
F-3.1.4: iCloud(권장) 또는 Firebase를 사용한 기기 간 실시간 동기화 (읽은 위치, 하이라이트, 메모).

3.2. AI 추천 엔진 (P1 - 높음)
F-3.2.1: 사용자의 독서 완료 이력, 장르 선호도, 하이라이트 키워드를 분석.
F-3.2.2: 홈 화면에 '회원님을 위한 맞춤 추천' 섹션 노출.
F-3.2.3: 추천 시 "AI가 분석한 추천 이유"를 한 문장으로 제공.

3.3. AI 독서 비서 (P1 - 높음)
F-3.3.1 (요약): 뷰어 내 'AI 요약' 버튼 제공. 챕터별/전체 요약 옵션 제공. (Gemini API 연동)
F-3.3.2 (노트): '내 노트' 탭에서 하이라이트/메모를 자동 생성된 태그(#인물, #핵심주장 등)로 필터링.
F-3.3.3 (Q&A): 뷰어 내 'AI에게 질문하기' 채팅창 제공. 현재 읽고 있는 책의 컨텍스트 내에서만 답변.

3.4. 독서 통계 대시보드 (P2 - 보통)
F-3.4.1: '내 서재' 탭에서 주간 독서 시간(막대그래프), 연속 독서일(Streak) 표시.

##4. 비기능 요구사항 (Non-Functional Requirements)

성능: 앱 로딩 시간 2초 이내. E-Book 페이지 넘김은 즉각적(<= 100ms)이어야 함. AI 기능은 5초 이내 응답 (로딩 인디케이터 필수).
플랫폼: SwiftUI를 사용하며 iOS 16.0 이상, macOS 13.0 이상 지원.
오프라인: E-Book 읽기, 하이라이트, 메모 등 핵심 기능은 오프라인에서 완벽하게 동작해야 함. (동기화는 온라인 시 수행)
데이터: 사용자 데이터(노트, 하이라이트)는 암호화되어 안전하게 저장되어야 함.
API: 모든 AI 기능은 Gemini API를 통해 호출하며, API Key는 클라이언트에 노출되지 않고 백엔드(BFF)를 통해 관리.
