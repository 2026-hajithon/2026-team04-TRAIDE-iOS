//
//  ScheduleRegistrationView.swift
//  TRAIDE
//

import SwiftUI

struct ScheduleRegistrationView: View {
    @Environment(NavigationRouter.self) private var router
    
    // MARK: - State (상태 관리)
    @State private var selectedDate: Date = Date()
    @State private var locationText: String = ""
    @State private var selectedCoach: String? = nil // 코치 선택 (필수)
    @State private var isAlarmOn: Bool = true // 알림 토글
    @State private var selectedAlarm: String? = "30분 전" // 알림 옵션
    
    // MARK: - Date Formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 EEEE" // 예: 8월 1일 토요일
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm" // 예: 오후 6:00
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    // MARK: - 버튼 활성화 유효성 검사 로직
    private var isFormValid: Bool {
        // 1. 코치 선택 필수
        guard selectedCoach != nil else { return false }
        
        // 2. 알림이 켜져 있다면, 알림 옵션도 반드시 선택되어야 함
        if isAlarmOn && selectedAlarm == nil { return false }
        
        // 장소는 (선택)이므로 검사하지 않음
        return true
    }
    
    var body: some View {
        VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("날짜")
                                .font(.pretendardMedium(14))
                                .foregroundStyle(Color(.customwhite))
                            
                            ZStack {
                                
                                customPickerBox(text: dateFormatter.string(from: selectedDate))
                                
                                
                                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .environment(\.locale, Locale(identifier: "ko_KR"))
                                    .colorMultiply(.clear)
                            }
                        }
                        
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("시간")
                                .font(.pretendardMedium(14))
                                .foregroundStyle(Color(.customwhite))
                            
                            ZStack {
                                customPickerBox(text: timeFormatter.string(from: selectedDate))
                                
                                DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .environment(\.locale, Locale(identifier: "ko_KR"))
                                    .colorMultiply(.clear)
                            }
                        }
                        
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("장소(선택)")
                                .font(.pretendardMedium(14))
                                .foregroundStyle(Color(.customwhite))
                            
                            TextField("강남 클라이밍장", text: $locationText)
                                .font(.pretendardMedium(14))
                                .padding()
                                .background(Color(._200))
                                .cornerRadius(8)
                                .foregroundStyle(Color(.customwhite))
                        }
                        
                        // MARK: 4. 코치 선택
                        VStack(alignment: .leading, spacing: 12) {
                            Text("코치 선택")
                                .font(.pretendardMedium(14))
                                .foregroundStyle(Color(.customwhite))
                            
                            HStack(spacing: 12) {
                                coachSelectionButton(title: "윤구리")
                                coachSelectionButton(title: "요가하는곰")
                            }
                        }
                        
                        // MARK: 5. 약속 전 미리 알림
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("약속 전 미리 알림")
                                    .font(.pretendardMedium(14))
                                    .foregroundStyle(Color(.customwhite))
                                
                                Spacer()
                                
                                Toggle("", isOn: $isAlarmOn.animation()) // 애니메이션 추가
                                    .tint(Color(.gMint))
                                    .labelsHidden()
                            }
                            
                            // 토글이 켜져 있을 때만 옵션 노출
                            if isAlarmOn {
                                HStack(spacing: 12) {
                                    alarmSelectionButton(title: "10분 전")
                                    alarmSelectionButton(title: "30분 전")
                                    alarmSelectionButton(title: "1시간 전")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                
                // MARK: 하단 등록 버튼
                MainBigButton(
                    text: "등록하기",
                    isDisabled: !isFormValid, // 모든 조건이 충족되지 않으면 비활성화
                    action: {
                        print("일정 등록 완료")
                        router.pop()
                    }
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(._100).ignoresSafeArea())
            .navigationTitle("일정 등록하기")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .customBackButton()
#if os(iOS)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(._100), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
#endif
    }
    
    // MARK: - Sub Views
    
    /// 날짜/시간 선택을 위한 커스텀 박스 UI (실제 피커는 이 아래에 숨겨져 있음)
    private func customPickerBox(text: String) -> some View {
        HStack {
            Text(text)
                .font(.pretendardMedium(14))
                .foregroundStyle(Color(.customwhite))
            Spacer()
            Image(systemName: "chevron.down")
                .font(.system(size: 14))
                .foregroundStyle(Color(._500))
        }
        .padding()
        .background(Color(._200))
        .cornerRadius(8)
    }
    
    /// 코치 선택 라디오 버튼
    private func coachSelectionButton(title: String) -> some View {
        let isSelected = (selectedCoach == title)
        
        return Button(action: {
            selectedCoach = title
        }) {
            HStack(spacing: 8) {
                // 라디오 동그라미
                Circle()
                    .strokeBorder(isSelected ? Color.clear : Color(._500), lineWidth: 1.5)
                    .background(Circle().fill(isSelected ? Color(.customwhite) : Color.clear))
                    .frame(width: 20, height: 20)
                
                Text(title)
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color(.customwhite))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.clear : Color(._200))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color(.gMint) : Color.clear, lineWidth: 1)
            )
        }
    }
    
    /// 알림 시간 선택 버튼
    private func alarmSelectionButton(title: String) -> some View {
        let isSelected = (selectedAlarm == title)
        
        return Button(action: {
            selectedAlarm = title
        }) {
            Text(title)
                .font(.pretendardMedium(14))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(isSelected ? Color.clear : Color(._200))
                .foregroundStyle(isSelected ? Color(.customwhite) : Color(._500))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color(.gMint) : Color.clear, lineWidth: 1)
                )
        }
    }
}

// MARK: - 프리뷰
#Preview {
    ScheduleRegistrationView()
        .environment(NavigationRouter())
}
