> 다국어 작업 시 엑셀 기반 으로 정리된 번역 문구를 JSON 산출물로 자동화 변환

![GUIDE-1](assets/@guide/json/Excel2Template_guide1.png)

> 다국어 작업 시 원래 기본적으로 단순 작업 리소스가 많은편인데 수동으로 기획 문구에 맞추서 개발 하던 부분을 간편하고 빠르게 산출물을 만들어 낼 수 있다.

---

## Excel Guide
![GUIDE-2](assets/@guide/json/Excel2Template_guide2.png)

- (1): Azure AD 인증 없는 `“잼팟외부”` 문서로 저장 (기획자에게 요청)
- (2): 컬럼 생성 후 (.) 기반으로 객체 네이밍 정의

---

## Use Guide
![GUIDE-3](assets/@guide/json/Excel2Template_guide3.png)

- (1): 엑셀 파일 첨부
  - 파일 확장자 .xlsx 만 첨부 가능 (Office365 엑셀 Open XML 기반)
- (2): 엑셀 > 시트네임을 연동한 선택 컨트롤러
- (3): 변환된 결과물 클립보드에 복사
  - 클립보드에 복사된 코드를 신규 `json` 파일 생성 후 붙여넣기
- (4): 초기화

---

## Preview
![GUIDE-4](assets/@guide/json/Excel2Template_guide4.png)
