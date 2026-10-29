-- PACK FIT / synthetic demo seed, October 2026
-- All size/weight values are hypothetical estimates, NOT product specifications.
-- Run this only in your demo Supabase project or a development database.
-- The demo tables are isolated from private user data.

CREATE TABLE IF NOT EXISTS public.item_presets (
    preset_id text PRIMARY KEY,
    name_ko text NOT NULL,
    category text NOT NULL,
    pack_state text NOT NULL,
    width_cm numeric(8,2) NOT NULL CHECK (width_cm > 0),
    length_cm numeric(8,2) NOT NULL CHECK (length_cm > 0),
    height_cm numeric(8,2) NOT NULL CHECK (height_cm > 0),
    weight_g integer NOT NULL CHECK (weight_g >= 0),
    flexible boolean NOT NULL DEFAULT false,
    fragile boolean NOT NULL DEFAULT false,
    compression_allowed boolean NOT NULL DEFAULT false,
    stackable boolean NOT NULL DEFAULT true,
    keep_upright boolean NOT NULL DEFAULT false,
    can_rotate boolean NOT NULL DEFAULT true,
    restriction_tag text NOT NULL DEFAULT 'none',
    bounding_volume_cm3 numeric(12,2) NOT NULL,
    data_quality text NOT NULL DEFAULT 'synthetic_estimate',
    notes text
);

CREATE TABLE IF NOT EXISTS public.demo_scenarios (
    scenario_id text PRIMARY KEY,
    name_ko text NOT NULL,
    inner_width_cm numeric(8,2) NOT NULL CHECK (inner_width_cm > 0),
    inner_length_cm numeric(8,2) NOT NULL CHECK (inner_length_cm > 0),
    inner_height_cm numeric(8,2) NOT NULL CHECK (inner_height_cm > 0),
    max_weight_g integer NOT NULL,
    expected_result text NOT NULL,
    notes text
);

CREATE TABLE IF NOT EXISTS public.demo_scenario_items (
    scenario_id text NOT NULL REFERENCES public.demo_scenarios(scenario_id) ON DELETE CASCADE,
    preset_id text NOT NULL REFERENCES public.item_presets(preset_id),
    quantity integer NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (scenario_id, preset_id)
);

-- Public, read-only demo data. No anonymous INSERT/UPDATE/DELETE policies.
ALTER TABLE public.item_presets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.demo_scenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.demo_scenario_items ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='item_presets' AND policyname='packfit_read_presets') THEN
        CREATE POLICY packfit_read_presets ON public.item_presets FOR SELECT TO anon, authenticated USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='demo_scenarios' AND policyname='packfit_read_scenarios') THEN
        CREATE POLICY packfit_read_scenarios ON public.demo_scenarios FOR SELECT TO anon, authenticated USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='demo_scenario_items' AND policyname='packfit_read_scenario_items') THEN
        CREATE POLICY packfit_read_scenario_items ON public.demo_scenario_items FOR SELECT TO anon, authenticated USING (true);
    END IF;
END $$;

BEGIN;

INSERT INTO public.item_presets (preset_id, name_ko, category, pack_state, width_cm, length_cm, height_cm, weight_g, flexible, fragile, compression_allowed, stackable, keep_upright, can_rotate, restriction_tag, bounding_volume_cm3, data_quality, notes) VALUES
  ('PRESET_001', '티셔츠', 'clothing', '접은 상태', 25.0, 20.0, 3.0, 200, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 1500.0, 'synthetic_estimate', '얇게 접은 성인용 상의'),
  ('PRESET_002', '긴팔 티셔츠', 'clothing', '접은 상태', 27.0, 21.0, 4.0, 270, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 2268.0, 'synthetic_estimate', '소재별로 두께 차이 큼'),
  ('PRESET_003', '셔츠', 'clothing', '접은 상태', 28.0, 22.0, 3.0, 240, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 1848.0, 'synthetic_estimate', '구김을 고려해 과압축 지양'),
  ('PRESET_004', '니트', 'clothing', '접은 상태', 30.0, 25.0, 7.0, 500, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 5250.0, 'synthetic_estimate', '접는 방식에 따라 높이 변화'),
  ('PRESET_005', '청바지', 'clothing', '접은 상태', 30.0, 25.0, 6.0, 750, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 4500.0, 'synthetic_estimate', '두꺼운 데님 바지'),
  ('PRESET_006', '면바지', 'clothing', '접은 상태', 30.0, 24.0, 5.0, 500, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 3600.0, 'synthetic_estimate', '일반 긴 바지'),
  ('PRESET_007', '반바지', 'clothing', '접은 상태', 25.0, 20.0, 4.0, 250, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 2000.0, 'synthetic_estimate', '면 반바지'),
  ('PRESET_008', '운동복 상의', 'clothing', '접은 상태', 25.0, 18.0, 3.0, 180, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 1350.0, 'synthetic_estimate', '가벼운 운동복'),
  ('PRESET_009', '운동복 하의', 'clothing', '접은 상태', 25.0, 20.0, 4.0, 250, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 2000.0, 'synthetic_estimate', '트레이닝 바지'),
  ('PRESET_010', '레깅스', 'clothing', '접은 상태', 22.0, 15.0, 3.0, 150, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 990.0, 'synthetic_estimate', '얇은 운동용'),
  ('PRESET_011', '후드티', 'clothing', '접은 상태', 32.0, 28.0, 9.0, 750, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 8064.0, 'synthetic_estimate', '두꺼운 후드'),
  ('PRESET_012', '맨투맨', 'clothing', '접은 상태', 30.0, 26.0, 7.0, 550, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 5460.0, 'synthetic_estimate', '기모 여부에 따라 다름'),
  ('PRESET_013', '경량 패딩', 'clothing', '접은 상태', 34.0, 27.0, 12.0, 700, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 11016.0, 'synthetic_estimate', '압축 후 더 작아질 수 있음'),
  ('PRESET_014', '재킷', 'clothing', '접은 상태', 36.0, 28.0, 10.0, 850, TRUE, FALSE, FALSE, FALSE, FALSE, TRUE, 'none', 10080.0, 'synthetic_estimate', '구김 주의'),
  ('PRESET_015', '원피스', 'clothing', '접은 상태', 32.0, 22.0, 5.0, 400, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 3520.0, 'synthetic_estimate', '소재별 구김 차이'),
  ('PRESET_016', '잠옷 세트', 'clothing', '접은 상태', 27.0, 23.0, 5.0, 380, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 3105.0, 'synthetic_estimate', '상하의 합산'),
  ('PRESET_017', '속옷 1개', 'clothing', '접은 상태', 15.0, 12.0, 2.0, 70, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 360.0, 'synthetic_estimate', '한 벌 기준'),
  ('PRESET_018', '양말 1켤레', 'clothing', '말은 상태', 12.0, 9.0, 4.0, 60, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 432.0, 'synthetic_estimate', '한 켤레 기준'),
  ('PRESET_019', '수영복', 'clothing', '접은 상태', 20.0, 15.0, 2.0, 110, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 600.0, 'synthetic_estimate', '수영복 1개'),
  ('PRESET_020', '일반 수건', 'clothing', '접은 상태', 28.0, 18.0, 6.0, 300, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 3024.0, 'synthetic_estimate', '중간 크기 타월'),
  ('PRESET_021', '비치타월', 'clothing', '접은 상태', 30.0, 25.0, 9.0, 650, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 6750.0, 'synthetic_estimate', '대형 타월'),
  ('PRESET_022', '스카프', 'clothing', '접은 상태', 18.0, 12.0, 3.0, 140, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 648.0, 'synthetic_estimate', '얇은 천 소재'),
  ('PRESET_023', '벨트', 'clothing', '말은 상태', 15.0, 15.0, 5.0, 170, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 1125.0, 'synthetic_estimate', '허리띠 한 개'),
  ('PRESET_024', '캡모자', 'clothing', '그대로', 25.0, 21.0, 12.0, 110, TRUE, FALSE, FALSE, FALSE, FALSE, TRUE, 'none', 6300.0, 'synthetic_estimate', '챙 변형 주의'),
  ('PRESET_025', '가벼운 장갑', 'clothing', '접은 상태', 17.0, 10.0, 3.0, 90, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 510.0, 'synthetic_estimate', '한 켤레'),
  ('PRESET_026', '운동화 한 켤레', 'footwear', '나란히 둔 상태', 34.0, 23.0, 13.0, 800, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, 'none', 10166.0, 'synthetic_estimate', '실제 신발 모양은 직육면체와 다름'),
  ('PRESET_027', '구두 한 켤레', 'footwear', '나란히 둔 상태', 36.0, 26.0, 14.0, 950, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, 'none', 13104.0, 'synthetic_estimate', '표면 눌림 주의'),
  ('PRESET_028', '샌들 한 켤레', 'footwear', '겹쳐 둔 상태', 30.0, 22.0, 10.0, 530, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 6600.0, 'synthetic_estimate', '스트랩 형태에 따라 차이'),
  ('PRESET_029', '슬리퍼 한 켤레', 'footwear', '겹쳐 둔 상태', 28.0, 20.0, 6.0, 250, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 3360.0, 'synthetic_estimate', '평평한 실내화'),
  ('PRESET_030', '쪼리 한 켤레', 'footwear', '겹쳐 둔 상태', 30.0, 20.0, 4.0, 220, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 2400.0, 'synthetic_estimate', '얇은 플립플롭'),
  ('PRESET_031', '부츠 한 켤레', 'footwear', '나란히 둔 상태', 38.0, 30.0, 20.0, 1250, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, 'none', 22800.0, 'synthetic_estimate', '높이가 높아 수납 어려움'),
  ('PRESET_032', '여행용 샴푸', 'toiletries', '용기 그대로', 5.0, 5.0, 13.0, 150, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, 'liquid_check', 325.0, 'synthetic_estimate', '밀봉 상태 및 항공사 규정 확인'),
  ('PRESET_033', '여행용 컨디셔너', 'toiletries', '용기 그대로', 5.0, 5.0, 13.0, 145, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, 'liquid_check', 325.0, 'synthetic_estimate', '밀봉 상태 확인'),
  ('PRESET_034', '여행용 바디워시', 'toiletries', '용기 그대로', 5.0, 5.0, 14.0, 160, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, 'liquid_check', 350.0, 'synthetic_estimate', '밀봉 상태 확인'),
  ('PRESET_035', '폼클렌저', 'toiletries', '튜브 그대로', 6.0, 5.0, 15.0, 180, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, 'liquid_check', 450.0, 'synthetic_estimate', '내용물 누출 주의'),
  ('PRESET_036', '칫솔 케이스', 'toiletries', '케이스 포함', 22.0, 4.0, 3.0, 80, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 264.0, 'synthetic_estimate', '개별 보관'),
  ('PRESET_037', '치약', 'toiletries', '튜브 그대로', 17.0, 5.0, 4.0, 100, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, 'liquid_check', 340.0, 'synthetic_estimate', '항공사 규정 확인'),
  ('PRESET_038', '기초 화장품 병', 'toiletries', '병 그대로', 7.0, 7.0, 15.0, 220, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, 'liquid_check', 735.0, 'synthetic_estimate', '유리 또는 단단한 용기 가정'),
  ('PRESET_039', '선크림', 'toiletries', '튜브 그대로', 5.0, 4.0, 12.0, 110, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, 'liquid_check', 240.0, 'synthetic_estimate', '항공사 규정 확인'),
  ('PRESET_040', '메이크업 파우치', 'toiletries', '내용물 포함', 24.0, 15.0, 8.0, 450, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, 'none', 2880.0, 'synthetic_estimate', '내부 물건 별도 중복 계산 금지'),
  ('PRESET_041', '빗', 'toiletries', '그대로', 20.0, 5.0, 3.0, 80, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 300.0, 'synthetic_estimate', '플라스틱 손잡이 빗'),
  ('PRESET_042', '면도기 케이스', 'toiletries', '케이스 포함', 16.0, 7.0, 4.0, 95, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'policy_check', 448.0, 'synthetic_estimate', '날 종류별 반입 정책 확인'),
  ('PRESET_043', '향수 병', 'toiletries', '병 그대로', 7.0, 7.0, 12.0, 300, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, 'liquid_check', 588.0, 'synthetic_estimate', '파손 위험 및 액체 제한 확인'),
  ('PRESET_044', '소형 구급 파우치', 'toiletries', '내용물 포함', 18.0, 12.0, 5.0, 250, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, 'policy_check', 1080.0, 'synthetic_estimate', '의약품 종류별 규정 확인'),
  ('PRESET_045', '물티슈 소포장', 'toiletries', '미개봉', 17.0, 10.0, 4.0, 150, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 680.0, 'synthetic_estimate', '물기 있는 부드러운 포장'),
  ('PRESET_046', '노트북 13인치', 'electronics', '보호 슬리브 포함', 34.0, 25.0, 3.0, 1500, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 'battery_check', 2550.0, 'synthetic_estimate', '기내/위탁 및 배터리 정책 확인'),
  ('PRESET_047', '태블릿', 'electronics', '케이스 포함', 26.0, 19.0, 2.0, 600, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 'battery_check', 988.0, 'synthetic_estimate', '배터리 정책 확인'),
  ('PRESET_048', '휴대전화', 'electronics', '케이스 포함', 16.0, 8.0, 2.0, 230, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 'battery_check', 256.0, 'synthetic_estimate', '배터리 정책 확인'),
  ('PRESET_049', '보조배터리', 'electronics', '그대로', 14.0, 7.0, 3.0, 250, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'battery_check', 294.0, 'synthetic_estimate', '항공 반입 제한 확인 필수'),
  ('PRESET_050', '카메라', 'electronics', '파우치 포함', 16.0, 12.0, 11.0, 700, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 'battery_check', 2112.0, 'synthetic_estimate', '렌즈 보호 및 배터리 규정 확인'),
  ('PRESET_051', '충전기+케이블', 'electronics', '묶은 상태', 12.0, 8.0, 5.0, 180, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 480.0, 'synthetic_estimate', '범용 충전 세트'),
  ('PRESET_052', '여행용 멀티어댑터', 'electronics', '그대로', 8.0, 7.0, 6.0, 150, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 336.0, 'synthetic_estimate', '멀티 플러그'),
  ('PRESET_053', '무선 이어폰 케이스', 'electronics', '케이스 포함', 8.0, 6.0, 4.0, 80, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 'battery_check', 192.0, 'synthetic_estimate', '배터리 정책 확인'),
  ('PRESET_054', '헤드폰', 'electronics', '케이스 포함', 23.0, 20.0, 10.0, 400, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 'battery_check', 4600.0, 'synthetic_estimate', '케이스 포함 수치'),
  ('PRESET_055', '휴대용 스피커', 'electronics', '그대로', 18.0, 8.0, 8.0, 430, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 'battery_check', 1152.0, 'synthetic_estimate', '배터리 정책 확인'),
  ('PRESET_056', '여권', 'travel', '지갑 포함', 15.0, 11.0, 2.0, 90, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'carry_on_recommended', 330.0, 'synthetic_estimate', '기내 소지 권장'),
  ('PRESET_057', '지갑', 'travel', '그대로', 12.0, 10.0, 3.0, 160, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'carry_on_recommended', 360.0, 'synthetic_estimate', '중요 소지품'),
  ('PRESET_058', '접이식 우산', 'travel', '접은 상태', 28.0, 6.0, 6.0, 260, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'policy_check', 1008.0, 'synthetic_estimate', '운송 규정 확인'),
  ('PRESET_059', '목베개', 'travel', '접은 상태', 30.0, 28.0, 12.0, 250, TRUE, FALSE, TRUE, FALSE, FALSE, TRUE, 'none', 10080.0, 'synthetic_estimate', '폼/에어 타입에 따라 차이'),
  ('PRESET_060', '선글라스 케이스', 'travel', '케이스 포함', 18.0, 8.0, 7.0, 170, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 'none', 1008.0, 'synthetic_estimate', '보호 케이스 기준'),
  ('PRESET_061', '세탁물 파우치', 'travel', '접은 상태', 25.0, 18.0, 2.0, 100, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 900.0, 'synthetic_estimate', '빈 파우치'),
  ('PRESET_062', '소형 패킹 큐브', 'travel', '내용물 포함', 25.0, 20.0, 8.0, 650, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 4000.0, 'synthetic_estimate', '내부 옷과 중복 입력 금지'),
  ('PRESET_063', '책', 'travel', '그대로', 21.0, 15.0, 3.0, 350, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 945.0, 'synthetic_estimate', '문고본보다 큰 책'),
  ('PRESET_064', '노트', 'travel', '그대로', 21.0, 15.0, 2.0, 250, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 630.0, 'synthetic_estimate', 'A5 수준 가정'),
  ('PRESET_065', '휴대용 삼각대', 'travel', '접은 상태', 35.0, 7.0, 7.0, 350, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'policy_check', 1715.0, 'synthetic_estimate', '길이/항공 반입 규정 확인'),
  ('PRESET_066', '긴 포스터 튜브', 'travel', '보호통 포함', 58.0, 9.0, 9.0, 480, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 4698.0, 'synthetic_estimate', '길이 초과 테스트용 물품'),
  ('PRESET_067', '과자 선물 상자', 'souvenir', '상자 포함', 25.0, 18.0, 8.0, 420, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 'food_check', 3600.0, 'synthetic_estimate', '잘 부서지는 포장 과자 가정'),
  ('PRESET_068', '초콜릿 선물상자', 'souvenir', '상자 포함', 18.0, 12.0, 4.0, 150, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 'food_check', 864.0, 'synthetic_estimate', '압력과 온도에 주의'),
  ('PRESET_069', '머그컵 선물상자', 'souvenir', '완충재 포함', 16.0, 16.0, 16.0, 430, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 'none', 4096.0, 'synthetic_estimate', '포장상자 기준'),
  ('PRESET_070', '유리컵 선물상자', 'souvenir', '완충재 포함', 14.0, 14.0, 18.0, 500, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 'none', 3528.0, 'synthetic_estimate', '취급 주의'),
  ('PRESET_071', '피규어 상자', 'souvenir', '상자 포함', 22.0, 16.0, 13.0, 330, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 'none', 4576.0, 'synthetic_estimate', '상자 보존 우선'),
  ('PRESET_072', '열쇠고리', 'souvenir', '포장 포함', 10.0, 8.0, 3.0, 30, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 'none', 240.0, 'synthetic_estimate', '소형 잡화'),
  ('PRESET_073', '기념 티셔츠', 'souvenir', '접은 상태', 25.0, 20.0, 3.0, 200, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 'none', 1500.0, 'synthetic_estimate', '쇼핑 후 추가'),
  ('PRESET_074', '음료 병', 'souvenir', '병 그대로', 8.0, 8.0, 25.0, 550, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, 'liquid_check', 1600.0, 'synthetic_estimate', '밀봉 및 항공 규정 확인')
ON CONFLICT (preset_id) DO NOTHING;

INSERT INTO public.demo_scenarios (scenario_id, name_ko, inner_width_cm, inner_length_cm, inner_height_cm, max_weight_g, expected_result, notes) VALUES
  ('S01', '기본 출국 · 20인치', 36, 50, 21, 10000, '배치 가능성 테스트', '부피가 남아도 실제 배치 가능 여부는 알고리즘 결과로 확인'),
  ('S02', '기념품 추가 · 20인치', 36, 50, 21, 10000, '부피 초과 테스트', '출국 짐에 기념품을 대량 추가한 가상 상황'),
  ('S03', '긴 여행 · 24인치', 43, 62, 26, 23000, '대용량 테스트', '다양한 물건 종류 및 깨지기 쉬운 물건 혼합'),
  ('S04', '긴 물건 · 20인치', 36, 50, 21, 10000, '회전해도 들어가지 않는 물건 테스트', '긴 포스터 튜브 58cm: 직교 회전만 허용하면 길이 초과')
ON CONFLICT (scenario_id) DO NOTHING;

INSERT INTO public.demo_scenario_items (scenario_id,preset_id,quantity) VALUES
  ('S01','PRESET_001',3),
  ('S01','PRESET_005',1),
  ('S01','PRESET_007',1),
  ('S01','PRESET_017',3),
  ('S01','PRESET_018',3),
  ('S01','PRESET_026',1),
  ('S01','PRESET_051',1),
  ('S01','PRESET_036',1),
  ('S01','PRESET_032',1),
  ('S01','PRESET_039',1),
  ('S01','PRESET_020',1),
  ('S01','PRESET_061',1),
  ('S02','PRESET_001',3),
  ('S02','PRESET_005',1),
  ('S02','PRESET_007',1),
  ('S02','PRESET_017',3),
  ('S02','PRESET_018',3),
  ('S02','PRESET_026',1),
  ('S02','PRESET_051',1),
  ('S02','PRESET_036',1),
  ('S02','PRESET_032',1),
  ('S02','PRESET_039',1),
  ('S02','PRESET_020',1),
  ('S02','PRESET_061',1),
  ('S02','PRESET_067',3),
  ('S02','PRESET_069',2),
  ('S02','PRESET_070',1),
  ('S02','PRESET_073',2),
  ('S02','PRESET_071',2),
  ('S03','PRESET_001',6),
  ('S03','PRESET_005',1),
  ('S03','PRESET_006',1),
  ('S03','PRESET_002',2),
  ('S03','PRESET_011',1),
  ('S03','PRESET_017',7),
  ('S03','PRESET_018',7),
  ('S03','PRESET_026',1),
  ('S03','PRESET_029',1),
  ('S03','PRESET_016',1),
  ('S03','PRESET_020',1),
  ('S03','PRESET_040',1),
  ('S03','PRESET_032',1),
  ('S03','PRESET_046',1),
  ('S03','PRESET_051',1),
  ('S03','PRESET_069',1),
  ('S04','PRESET_001',2),
  ('S04','PRESET_018',2),
  ('S04','PRESET_066',1),
  ('S04','PRESET_051',1)
ON CONFLICT (scenario_id,preset_id) DO NOTHING;

COMMIT;
