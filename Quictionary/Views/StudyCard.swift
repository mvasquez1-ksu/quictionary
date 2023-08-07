//
//  StudyCard.swift
//  Quictionary
//
//  Created by Marco Vasquez on 3/28/23.
//  View displaying entry as a card that can be flipped and swiped

import SwiftUI

struct StudyCard: View {
    // Controller
    @EnvironmentObject var dictionaryController: DictionaryController
    // Closure indicating if card has been swiped away
    var removal: (() -> Void)? = nil
    // The card's offset on the screen
    @State private var offset = CGSize.zero
    // Boolean value indicating if card is flipped
    @State private var flipped = false
    // Card's rotation value
    @State var cardRotation = 0.0
    // Content's rotation value
    @State var contentRotation = 0.0
    // Selected dictionary entry
    var dictionaryEntry: DictionaryEntry
    
    init(dictionaryEntry: DictionaryEntry, _ closure: @escaping () -> Void) {
        self.dictionaryEntry = dictionaryEntry
        removal = closure
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.quicGreen)
                .shadow(radius: 5)
                .rotation3DEffect(
                    .degrees(flipped ? 180 : 0),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
            VStack {
                Spacer()
                if flipped {
                    Text("Definition")
                        .foregroundColor(.white)
                    Text(dictionaryEntry.definition ?? "")
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()
                }
                else {
                    Text("Word")
                        .foregroundColor(.white)
                    Text(dictionaryEntry.word ?? "")
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()
                }
                Spacer()
            }
        }
        .rotation3DEffect(.degrees(contentRotation), axis: (x: 0, y: 1, z: 0))
        .padding()
        .onTapGesture {
            flipCard()
        }
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 40)))
        .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
        .opacity(2 - Double(abs(offset.width / 150)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if flipped {
                        offset = CGSize(width: -gesture.translation.width, height: gesture.translation.height)
                    }
                    else {
                        offset = gesture.translation
                    }

                } .onEnded { _ in
                    withAnimation {
                        swipeCard(width: offset.width)
                    }
                }
        )
    }
    
    // Handles the card being swiped left/right
    private func swipeCard(width: CGFloat) {
        if (flipped) {
            switch width {
            case 150...500:
                offset = CGSize(width: -500, height: 0)
                dictionaryController.forgetCard(entry: dictionaryEntry)
                print("Card forgotten")
                removal?()
            case -500...(-150):
                offset = CGSize(width: 500, height: 0)
                dictionaryController.rememberCard(entry: dictionaryEntry)
                print("Card remembered")
                removal?()
            default:
                offset = .zero
            }
        }
        else {
            switch width {
            case -500...(-150):
                offset = CGSize(width: -500, height: 0)
                dictionaryController.forgetCard(entry: dictionaryEntry)
                print("Card forgotten")
                removal?()
            case 150...500:
                offset = CGSize(width: 500, height: 0)
                dictionaryController.rememberCard(entry: dictionaryEntry)
                print("Card remembered")
                removal?()
            default:
                offset = .zero
            }
        }
    }
    
    // Handles flipping card
    private func flipCard() {
        let animationTime = 0.5
        withAnimation(Animation.linear(duration: animationTime)) {
            cardRotation += 180
        }
        
        withAnimation(Animation.linear(duration: 0.001).delay(animationTime / 2)) {
            contentRotation += 180
            flipped.toggle()
        }
    }
}

struct StudyCard_Previews: PreviewProvider {
    static var previews: some View {
        StudyCard(dictionaryEntry: DictionaryEntry(context: PersistenceController.preview.container.viewContext), {})
    }
}
