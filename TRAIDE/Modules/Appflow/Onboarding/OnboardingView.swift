//
//  OnboardingView.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI

// MARK: - 공통 레이아웃 컴포넌트
struct OnboardingLayout<Content: View>: View {
    let title: String
    let buttonText: String
    let isButtonDisabled: Bool
    let showBackButton: Bool
    
    let backAction: () -> Void
    let nextAction: () -> Void
    
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // 커스텀 네비게이션 바 (뒤로 가기)
            HStack {
                if showBackButton {
                    Button(action: {
                        backAction()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color("customwhite"))
                    })
                }
                Spacer()
            }
            .frame(height: 44)
            .padding(.bottom, -10)
            
            // 공통 타이틀
            Text(title)
                .font(.pretendardBold(24))
                .foregroundStyle(Color("customwhite"))
                .lineSpacing(6)
            
            // 컨텐츠 영역
            content
            
            Spacer()
            
            // 공통 하단 버튼
            MainBigButton(
                text: buttonText,
                isDisabled: isButtonDisabled,
                action: nextAction
            )
        }
        .padding(.horizontal, 20)
        .background(Color(._100).ignoresSafeArea())
    }
}

// MARK: - 메인 온보딩 뷰
struct OnboardingView: View {
    @State private var currentStep: OnboardingStep = .basicInfo
    @State private var viewModel = OnboardingViewModel()
    @State private var isRegionSheetPresented: Bool = false
    @State private var showMain: Bool = false
    private let seoulDistricts: [String] = [
        "강남구","강동구","강북구","강서구","관악구","광진구","구로구","금천구","노원구","도봉구","동대문구","동작구","마포구","서대문구","서초구","성동구","성북구","송파구","양천구","영등포구","용산구","은평구","종로구","중구","중랑구"
    ]
    
    var body: some View {
        ZStack {
            Color(._100).ignoresSafeArea() // 전체 배경 일괄 적용
            
            switch currentStep {
            case .loginInfo:
                loginInfoStep
            case .basicInfo:
                basicInfoStep
            case .profile:
                profileStep
            case .sportsTalent:
                sportsTalentStep
            case .welcome:
                welcomeStep
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep) // 부드러운 전환 애니메이션
#if os(iOS)
        .fullScreenCover(isPresented: $showMain) {
            MainTabView()
        }
#elseif os(macOS)
        .sheet(isPresented: $showMain) {
            MainTabView()
                .frame(minWidth: 800, minHeight: 600)
        }
#endif
    }
}

// MARK: - 개별 단계 뷰 (Extension)
extension OnboardingView {
    
    // 1단계: 기본 정보
    private var basicInfoStep: some View {
        OnboardingLayout(
            title: "반가워요!\n기본 정보를 입력해주세요",
            buttonText: "다음",
            isButtonDisabled: false,
            showBackButton: false,
            backAction: { },
            nextAction: { currentStep = .loginInfo }
        ) {
            VStack(alignment: .leading, spacing: 10) {
                Text("성별")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color("customwhite"))
                
                // 성별 선택 임시 UI
                HStack {
                    Text("남")
                        .frame(maxWidth: .infinity).padding().background(Color(._200)).cornerRadius(8)
                    Text("여")
                        .frame(maxWidth: .infinity).padding().background(Color(._200)).cornerRadius(8)
                }
                .foregroundStyle(Color("customwhite"))
                
                Text("나이")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color("customwhite"))
                    .padding(.top, 20)
                
                TextField("입력해주세요", text: $viewModel.age)
                    .padding()
                    .background(Color(._200))
                    .cornerRadius(8)
                    .foregroundStyle(Color("customwhite"))
            }
        }
    }
    
    // 2단계: 로그인 정보
    private var loginInfoStep: some View {
        OnboardingLayout(
            title: "로그인 정보를\n입력해주세요",
            buttonText: "다음",
            isButtonDisabled: false,
            showBackButton: true,
            backAction: { currentStep = .basicInfo },
            nextAction: { currentStep = .profile }
        ) {
            VStack(alignment: .leading, spacing: 10) {
                Text("아이디")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color("customwhite"))
                TextField("입력해주세요", text: $viewModel.id)
                    .padding().background(Color(._200)).cornerRadius(8)
                
                Text("비밀번호")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color("customwhite"))
                    .padding(.top, 10)
                SecureField("입력해주세요", text: $viewModel.pw)
                    .padding().background(Color(._200)).cornerRadius(8)
            }
        }
    }
    
    // 3단계: 프로필 설정
    private var profileStep: some View {
        OnboardingLayout(
            title: "사용하실 프로필을\n설정해주세요",
            buttonText: "다음으로",
            isButtonDisabled: false,
            showBackButton: true,
            backAction: { currentStep = .loginInfo },
            nextAction: { currentStep = .sportsTalent }
        ) {
            VStack(spacing: 40) {
                // 프로필 이미지 영역
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(Color(._300))
                        .frame(width: 120, height: 120)
                        .overlay {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(35)
                                .foregroundColor(Color(._400))
                        }
                    
                    Button(action: {
                        // TODO: 사진 앨범 접근 로직
                    }, label: {
                        Circle()
                            .fill(Color(._400))
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: "camera")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("customwhite"))
                            }
                    })
                    .offset(x: -5, y: -5)
                }
                .padding(.top, 20)
                
                // 이름 입력 폼
                VStack(alignment: .leading, spacing: 8) {
                    Text("이름")
                        .font(.pretendardMedium(12))
                        .foregroundStyle(Color("customwhite"))
                    
                    TextField("입력해주세요", text: $viewModel.nickname)
                        .padding()
                        .background(Color(._200))
                        .cornerRadius(8)
                        .foregroundStyle(Color("customwhite"))
                }
            }
        }
    }
    
    // 4단계: 운동 재능
    private var sportsTalentStep: some View {
        OnboardingLayout(
            title: "내가 가진 운동 재능을\n알려주세요!",
            buttonText: "다음으로",
            isButtonDisabled: false,
            showBackButton: true,
            backAction: { currentStep = .profile },
            nextAction: { currentStep = .welcome }
        ) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 35) {
                    
                    // 1. 잘하는 운동 섹션
                    VStack(alignment: .leading, spacing: 16) {
                        Text("잘하는 운동")
                            .font(.pretendardMedium(16))
                            .foregroundStyle(Color("customwhite"))
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                ForEach(["농구", "축구", "테니스", "배드민턴", "탁구"], id: \.self) { sport in
                                    sportTag(title: sport)
                                }
                            }
                            HStack(spacing: 10) {
                                ForEach(["수영", "헬스", "클라이밍", "러닝"], id: \.self) { sport in
                                    sportTag(title: sport)
                                }
                            }
                        }
                    }
                    
                    // 2. 숙련도 섹션
                    VStack(alignment: .leading, spacing: 16) {
                        Text("숙련도")
                            .font(.pretendardMedium(16))
                            .foregroundStyle(Color("customwhite"))
                        
                        VStack(spacing: 10) {
                            proficiencyCard(badge: "고인물", description: "실전 노하우와 기술까지 알려드릴 수 있어요")
                            proficiencyCard(badge: "지역 대표", description: "기본기를 넘어 응용까지 알려드릴 수 있어요")
                            proficiencyCard(badge: "워밍업", description: "기본 동작과 규칙을 알려드릴 수 있어요")
                        }
                    }
                    
                    // 3. 활동 지역 섹션
                    VStack(alignment: .leading, spacing: 16) {
                        Text("활동 지역")
                            .font(.pretendardMedium(16))
                            .foregroundStyle(Color("customwhite"))
                        
                        Button(action: {
                            isRegionSheetPresented = true
                        }, label: {
                            HStack {
                                Text(viewModel.region.isEmpty ? "선택해주세요" : viewModel.region)
                                    .foregroundStyle(viewModel.region.isEmpty ? Color(._400) : Color("customwhite"))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(Color(._400))
                            }
                            .padding()
                            .background(Color(._200))
                            .cornerRadius(8)
                        })
                    }
                }
                .padding(.bottom, 20)
            }
            .sheet(isPresented: $isRegionSheetPresented) {
                NavigationStack {
                    List(seoulDistricts, id: \.self) { district in
                        Button(action: {
                            viewModel.region = district
                            isRegionSheetPresented = false
                        }, label: {
                            HStack {
                                Text(district)
                                    .foregroundStyle(Color("customwhite"))
                                Spacer()
                                if viewModel.region == district {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color("g_blue"))
                                }
                            }
                        })
                        .listRowBackground(Color(._100))
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color(._100))
                    .navigationTitle("활동 지역 선택")
                    .toolbar {
                        ToolbarItem() {
                            Button("닫기") {
                                isRegionSheetPresented = false
                            }
                        }
                    }
                }
                .preferredColorScheme(.dark)
            }
        }
    }
    
    // 5단계: 완료 화면
    private var welcomeStep: some View {
        VStack {
            Spacer()
            
            Text("\(viewModel.nickname.isEmpty ? "근육젤리" : viewModel.nickname) 님, 함께 운동을 교류할\n메이트를 찾아볼까요?")
                .font(.pretendardBold(24))
                .foregroundStyle(Color("customwhite"))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            
            Spacer()
            
            MainBigButton(
                text: "시작하기",
                isDisabled: false,
                action: {
                    viewModel.submitData()
                    print("온보딩 완료: 앱 메인 화면으로 이동")
                    showMain = true
                    // TODO: UserDefaults 등에 온보딩 완료 플래그 저장 및 메인 뷰 전환
                }
            )
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Sub Views (운동 재능 화면용 헬퍼)
    
    /// 운동 종목 태그 뷰
    private func sportTag(title: String) -> some View {
        let isSelected = viewModel.selectedSports.contains(title)
        
        return Button(action: {
            if isSelected {
                viewModel.selectedSports.removeAll(where: { $0 == title })
            } else {
                viewModel.selectedSports.append(title)
            }
        }, label: {
            Text(title)
                .font(.pretendardMedium(14))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                // 1. 박스 배경은 항상 회색으로 통일
                .background(Color(._200))
                // 2. 텍스트가 선택 시 그라데이션 틴트 되게 하기
                .foregroundStyle(
                    isSelected ?
                    AnyShapeStyle(LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)) :
                    AnyShapeStyle(Color(._500))
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? AnyShapeStyle(LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(Color.clear),
                            lineWidth: 1
                        )
                )
        })
    }
    
    /// 숙련도 선택 카드 뷰
    private func proficiencyCard(badge: String, description: String) -> some View {
        let isSelected = (viewModel.proficiency == badge)
    
        return Button(action: {
            viewModel.proficiency = badge
        }, label: {
            HStack(spacing: 12) {
                Text(badge)
                    .font(.pretendardMedium(14))
                    .foregroundStyle(isSelected ? Color("customblack") : Color(._500))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        isSelected ? AnyShapeStyle(LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(Color(._300))
                    )
                    .cornerRadius(4)
                
                Text(description)
                    .font(.pretendardRegular(14))
                    // 3. 설명 텍스트가 선택 시 그라데이션 틴트 되게 하기
                    .foregroundStyle(
                        isSelected ?
                        AnyShapeStyle(LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)) :
                        AnyShapeStyle(Color(._500))
                    )
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            // 박스 배경은 항상 회색으로 통일
            .background(Color(._200))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? AnyShapeStyle(LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(Color.clear),
                        lineWidth: 1
                    )
            )
        })
    }
}

// MARK: - 프리뷰
#Preview {
    OnboardingView()
}

