# PencilKitSample

## Hierarchy

* ViewController.swift
    > RootViewController
* Scribble
    > 드로잉 관련 기능을 구현
    * ScribbleViewController.swift
    * ScribbleViewModel.swift
    * AnnotationListTableViewController.swift
        > 저장된 드로잉 목록 UI
    * Drawing
        > 드로잉 기능 모듈
* Model.swift
    > CoreData를 다루기 위한 모델
* Resources
    * sample_science.pdf
        > pdf 샘플파일

## Dependency
> Swift Package Manager만 사용합니다.

* RxSwift
* RxGesture
* RxDataSources
* SnapKit
* Then
* Thoth (개인적으로 만든 유용한 익스텐션 모음입니다.)

## Features

* PDF 열람 (줌, 핀치, 페이징)
* PDF 마킹 기능
    > 현재 임시로 CoreData에 마킹 내용을 data로 변환하여 저장하고 있습니다. 서버가 지원되면 CoreData를 제거하고 변환된 마킹을 전송해야 합니다.
    * pdf에 마킹을 하고 저장
    * 저장된 마킹을 목록으로 조회
    * 선택한 마킹을 pdf에 복원
* 기화펜 기능 `(미구현)`
    * 지정된 시간에 마킹한 내용이 사라짐

## Attentions

* 애플펜슬이 없는 경우 DrawingGestureRecognizer.swift(22)의 ```touch.type == .pencil,```을 주석처리면 손으로도 가능 합니다.
* 단 이경우 제스쳐로 페이지를 넘길 수 없는 문제가 있습니다.
* 마킹 복원시 마킹의 두께가 얇게 나오는 부분의 수정이 필요합니다.
