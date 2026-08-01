//
//  OnboardingViewModel.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import Foundation
import Observation


@Observable
class OnboardingViewModel {
    var gender: String = ""
    var age: String = ""
    var id: String = ""
    var pw: String = ""
    var nickname: String = ""
    
    //상태변수
    var selectedSports: [String] = [] // 다중 선택된 운동
    var proficiency: String = ""      // 선택된 숙련도
    var region: String = ""           // 선택된 지역
    
    func submitData() {
        print("서버 전송 완료: \(nickname), 운동: \(selectedSports), 숙련도: \(proficiency)")
    }
}
