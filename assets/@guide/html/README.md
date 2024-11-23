> 다국어 작업 시 엑셀 기반 으로 정리된 번역 문구를 HTML 산출물로 자동화 변환

![GUIDE-1](assets/@guide/html/Excel2Template_guide1.png)

> 다국어 작업 시 원래 기본적으로 단순 작업 리소스가 많은편인데 아무래도 개발 파트보다 마크업 파트쪽이 정적 파일로 산출물로 관리해줘야 하기 때문에 가장 반복 작업량(복사 + 붙여넣기) 리소스가 많을 수 밖에 없음.
> 수동으로 기획 문구에 맞추서 퍼블리싱 하던 부분을 간편하고 빠르게 산출물을 만들어 낼 수 있다.

---

## Excel Guide
![GUIDE-2](assets/@guide/html/Excel2Template_guide2.png)

- (1): Azure AD 인증 없는 `“잼팟외부”` 문서로 저장 (기획자에게 요청)
- (2): 컬럼 생성 후 다국어 정리된 문구 셀 위치 값 정의 (예 B1)
  - 엑셀 자동화 인덱스 추가 기능 사용 권장

## HTML Template Guide
``` html
<ul class="list">
	<li>
		<strong class="stit">
			{{@B2}}
		</strong>
		<p>{{@B3}}</p>
	</li>
	<li>
		<strong class="stit">
			{{@B4}}
		</strong>
		<p>{{@B5}}</p>
	</li>
</ul>
```

---

## Use Guide
![GUIDE-3](assets/@guide/html/Excel2Template_guide3.png)

- (1): 엑셀 파일 첨부
  - 파일 확장자 .xlsx 만 첨부 가능 (Office365 엑셀 Open XML 기반)
- (2): 엑셀 > 시트네임을 연동한 선택 컨트롤러
- (3): 템플릿 파일 첨부
  - 파일 확장자 .html 만 첨부 가능
- (4): 엑셀 문구 ↔︎ HTML 템플릿에 바인딩 되어 변환된 결과물 클립보드에 복사
  - 클립보드에 복사된 코드를 신규 `html` 파일 생성 후 붙여넣기
- (5): 초기화
