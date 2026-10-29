# 🧳 PACK FIT (팩 핏)

> **"짐은 네가 고르고, 배치는 우리가 한다."**

대학생 바이브코딩 대회 출품작 — **AI Vision과 3D Bin Packing 알고리즘을 결합한 모바일 중심 스마트 캐리어 패킹 웹앱**

---

## 📌 1\. 프로젝트 개요

**PACK FIT**은 여행자가 가져갈 물건들을 사진으로 촬영하거나 목록으로 입력하면, AI가 물건을 인식하고 캐리어의 물리적 치수와 물건의 특성(무게, 파손 주의, 변형 가능 여부)을 분석하여 **가장 효율적인 3D 수납 배치 방법과 순서**를 안내하는 서비스입니다.

---

## 🎯 2\. 핵심 사용자 경험 (4단계 프로세스)

1. **회원가입 / 로그인 (`AuthScreen`)**  
   - 게스트 모드 또는 이메일 계정으로 손쉽게 서비스를 시작합니다.  
2. **여행 정보 및 캐리어 설정 (`TripInfoScreen`)**  
   - 여행지(도쿄/오사카, 다낭, 유럽 등) 및 일정(출발일\~도착일)을 입력합니다.  
   - 20인치/24인치/28인치 프리셋 또는 커스텀 가로·세로·높이(cm) 및 최대 허용 무게(kg)를 설정합니다.  
3. **AI 맞춤 짐 싸기 텍스트 추천 (`AiRecommendScreen`)**  
   - 여행지의 기후 및 일정 특성에 맞춰 AI가 꼭 챙겨야 할 준비물 조언과 기본 체크리스트를 제안합니다.  
4. **촬영 이미지 AI 배치 및 3D 최적화 (`AiScanScreen` ➔ `Packing3DScreen`)**  
   - 짐을 바닥에 펼쳐놓고 사진을 찍으면 Vision AI가 물품과 크기를 자동 추출합니다.  
   - **3D Bin Packing Engine**이 직육면체 6방향 회전, 무게중심 하단 배치, 파손품 상단 보호 규칙을 고려해 최적 배치를 계산합니다.  
   - 회전 가능한 3D 캐리어 Visualizer를 통해 Step-by-Step 수납 순서를 확인합니다.

---

## 🛠 3\. 기술 스택 (Tech Stack)

| 구분 | 사용 기술 |
| :---- | :---- |
| **Framework** | Next.js / React / TypeScript |
| **Styling** | Tailwind CSS (Glassmorphism UI) |
| **3D Rendering** | Three.js (WebGL Visualizer) |
| **Icons** | Lucide React |
| **AI Vision & Text** | Google Gemini 3 Flash Vision API |
| **Bin Packing Engine** | Custom 3D Bottom-Left-Front Greedy Placement with 6-Way Orientations |
| **Data Storage** | Browser Local Storage (향후 Supabase 연동 가능 구조) |

---

## 📂 4\. 권장 프로젝트 폴더 구조

```
pack-fit/
├── public/
│   └── favicon.ico
├── src/
│   ├── app/
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── components/
│   │   ├── auth/
│   │   │   └── AuthScreen.tsx
│   │   ├── trip/
│   │   │   ├── TripInfoScreen.tsx
│   │   │   └── AiRecommendScreen.tsx
│   │   ├── 3d/
│   │   │   ├── Packing3DScreen.tsx
│   │   │   └── SuitcaseMesh.tsx
│   │   └── items/
│   │       ├── AiScanScreen.tsx
│   │       └── ItemListScreen.tsx
│   ├── lib/
│   │   ├── packFitEngine.ts   # 3D Bin Packing 물리 계산 코어
│   │   └── geminiVision.ts    # Vision AI 연동 모듈
│   └── types/
│       └── index.ts           # Suitcase, PackingItem, Placement 등 데이터 모델
├── .env.example
├── pack_fit_app.html          # 브라우저 실행용 Single File MVP
├── package.json
└── README.md
```

---

## ⚙️ 5\. 데이터 모델 (Data Model)

```ts
export interface Suitcase {
  id: string;
  name: string;
  innerWidth: number;  // cm (X)
  innerHeight: number; // cm (Y)
  innerDepth: number;  // cm (Z)
  maxWeight: number;   // kg
}

export interface PackingItem {
  id: string;
  name: string;
  category: '의류' | '전자기기' | '세면도구' | '신발' | '잡화';
  quantity: number;
  width: number;
  height: number;
  depth: number;
  weight: number;
  fragile: boolean;    // 파손 주의 여부
  flexible: boolean;   // 의류 등 접힘/변형 가능 여부
  source: 'preset' | 'ai_vision' | 'manual' | 'return_shopping';
}

export interface PackingPlacement {
  instanceId: string;
  itemId: string;
  positionX: number;
  positionY: number;
  positionZ: number;
  width: number;
  height: number;
  depth: number;
  rotation: number;     // 0~5 (6가지 3D 회전 상태)
  packingOrder: number; // 수납 순서 Step
  packed: boolean;
}
```

---

## 🚀 6\. 실행 방법

### 환경 변수 설정 (`.env.local`)

```sh
NEXT_PUBLIC_GEMINI_API_KEY=your_gemini_api_key_here
```

> ※ API 키가 없어도 시뮬레이션 데모 모드로 완벽하게 구동됩니다.

### MVP 단일 파일 실행

`pack_fit_app.html` 파일을 웹 브라우저(Chrome, Edge, Safari 등)로 직접 열면 서버 설치 없이 바로 3D 배치 알고리즘과 인터랙티브 UI를 테스트할 수 있습니다.