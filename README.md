# 최적의 음식점 찾기(Backend Laravel)

> 현재위치와 음식종류 그리고 +a 로 최적의 음식점을 찾아보자  
> 첫 작성, 최대 일주일간 아이디어만 내볼 것

# 시작 전

## 1. 계기

- 나는 퇴근하고 그분과 함께 무엇을 먹으면 좋을지 생각이 나지 않는다.
- 미리 생각안하고 계획없다고 혼이 난다.
- 그래도 난 업무시간엔 생각할 수 없다! 개발을 열심히!
- 지금도 혼나고 먼길 돌아와 공부할겸 한번 만들어본다.

## 2. 방향

- 모두 새로 접하는 기술이기 때문에 Study Log 작성하기
- 꾸준하게 + 데드라인 잡기
  - 벌써 오랜만에 들어옴. 그래서 꾸준함을 위해 날짜나 시간을 정할 필요가 있음.
- 진행하다보니 공부 목적으로 시작한 프로젝트라 다른 사이트의 API를 조회하거나 크롤링하여 데이터를 제공할 필요가 없음.
  - 서비스 목적이 아닌데 어느 순간 그렇게 진행하고 있었음.
  - 모두 직접 구현해보며 라라벨과 좋은 디자인 패턴을 익히는 것이 목적.
- 은 아님. 서비스 가능하도록 해야한다는 생각.

## 3. Todo

- [x] JWT Auth
- 음식점
  - [x] CRUD
  - [] 검색 및 필터링
- 음식점 좋아요
  - [] 리스트
  - [x] 추가, 삭제

- 추천 기능
  - 날씨, 거리에 따라
- 유저별 기능 추가
  - 사장님
    - 웨이팅 인원, 예상대기시간, 재료소진 등 휴무 등록
  - 회원
    - 평점과 간단한 리뷰
- 검색 순위

---

# 시작

## 개발환경 세팅

1. `docker-compose up -d --build`
2. `composer install`
3. `cp .env.example .env`
4. `php artisan key:generate`

## 개발 정리

1. Repository pattern
    - 목적
        - `domain`과 `persistent layer` 의 분리
        - 즉 데이터베이스, 파일 시스템, 외부 서비스 등의 저장된 데이터에 액세스 할 수 있는 인터페이스를 제공
        - 모델과 컨트롤러 사이에 브리지를 만들고, 모델이 외부 데이터와 통신하거나 데이터를 추출할 책임을 없앤다

    - 장점
        - 데이터 엑세스 로직의 중앙 집중화로 코드 유지 관리 용이
        - 코드 중복 감소
        - 비즈니스 및 데이터 액세스 로직 별도 테스트
        - 프로그래밍 오류 발생 가능성 감소

    - 사용 방법
        - RepositoryInterface 에서 메소드 정의
        - Repository 에서 Eloquent 기능을 사용하여 구현
            - Eloquent를 사용하지 않는다면 같은 위치에 다른 디렉터리를 추가하고 구현부만 새로 작성
            - Ex) App\Repository\Mongo\UserRepository
        - Controller 는 Repository의 구현을 사용

    - 규칙
        - 1 Repository : 1 Interface
        - `new` 키워드 대신 항상 `Dependency Injection`을 사용하라. 타입은 구현이 아닌 `인터페이스`를 주입하라. 단위테스트 작성이 쉬워진다.
        - 메소드가 많은 `Repository` 에서 사용될 경우 `BaseRepository`에 구현하라.
        - 생성자에 모델을 주입할 때 `Static Class`를 사용하지 마라. 그러면 단위테스트에서 쉽게 `mock` 할 수 있다.

    - 결론
        - `Repository Class`를 제외한 모든 곳에서는 `Eloquent`를 사용하면 안된다.
            - Laravel에서 `Eloquent`를 사용하지 못하는 다른 데이터 엔진으로 바꿀 경우를 생각한다면 말이다.
            - 해당 포스트의 댓글에서도 알 수 있듯이 결국 다른 곳에서 사용하지 않는 것은 매우 어렵다.
            - 결국 이 방식의 목적은 `라라벨`에서 쉬운 방법으로 `충분히 높은` 품질의 `Repository Pattern`을 구현하도록 한 것이다.

    - 최종 개발 규칙
        - 데이터 엔진을 바꾼다는 생각은 하지 않도록 한다.
        - 데이터 액세스는 최대한 `Repository`를 통해서 접근하고, 그로 인해 로직의 중복제거 및 유지관리를 용이하게 한다.
        - 모델은 `Repository Class` 에만 주입하여 사용한다.

2. 그렇다면 비즈니스 로직 작성은 어디에서 할 것인가?
    - `Service` 레이어를 추가한다.
    - `Controller` -> `Repository` 또는 `Controller` -> `Service` ->`Repository` 로 데이터를 요청한다.