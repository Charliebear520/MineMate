import SwiftUI

struct DateBarView: View {
    @ObservedObject var viewModel: LoginRecordViewModel
    var onDateTapped: ((Date) -> Void)? = nil
    @GestureState private var dragOffset: CGFloat = 0
    @State private var animateOffset: CGFloat = 0
    @State private var isAnimating = false

    var body: some View {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(byAdding: .weekOfYear, value: viewModel.currentWeekOffset, to: calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!)!
        let daySymbols = calendar.shortWeekdaySymbols // 保證日~六縮寫長度一致

        HStack(spacing: 12) {
            ForEach(0..<7, id: \ .self) { offset in
                let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
                let isToday = calendar.isDate(date, inSameDayAs: today)
                let isRecorded = viewModel.recordedDates.contains(where: { calendar.isDate($0, inSameDayAs: date) })
                let isSelected = viewModel.selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false
                let weekdayIndex = (calendar.component(.weekday, from: date) - calendar.firstWeekday + 7) % 7
                VStack(spacing: 6) {
                    Text(daySymbols[weekdayIndex])
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(width: 32) // 固定寬度，避免跑版
                    ZStack {
                        Circle()
                            .fill(isRecorded ? Color.white : Color.gray.opacity(0.18))
                            .frame(width: 38, height: 38)
                            .overlay(
                                Circle()
                                    .stroke(isToday ? Color.accentColor : (isSelected ? Color.yellow : Color.clear), lineWidth: 2)
                            )
                        Text("\(calendar.component(.day, from: date))")
                            .foregroundColor(isRecorded ? .black : .gray)
                            .fontWeight(isToday ? .bold : .regular)
                    }
                    .onTapGesture {
                        viewModel.selectDate(date)
                        onDateTapped?(date)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .background(Color.black)
        .offset(x: animateOffset + dragOffset)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    if value.translation.width < -40 {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            animateOffset = -UIScreen.main.bounds.width
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                            viewModel.goToNextWeek()
                            animateOffset = UIScreen.main.bounds.width
                            withAnimation(.easeInOut(duration: 0.22)) {
                                animateOffset = 0
                            }
                        }
                    } else if value.translation.width > 40 {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            animateOffset = UIScreen.main.bounds.width
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                            viewModel.goToPreviousWeek()
                            animateOffset = -UIScreen.main.bounds.width
                            withAnimation(.easeInOut(duration: 0.22)) {
                                animateOffset = 0
                            }
                        }
                    }
                }
        )
    }
} 