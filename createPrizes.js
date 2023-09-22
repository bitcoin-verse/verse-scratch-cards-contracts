// [
//     100,  3, 58, 76, 12, 38, 29, 44,  4, 97, 68,  8,
//      39, 75, 64, 10, 60, 77,  6, 41, 89, 81, 13, 88,
//      37, 65, 20, 32, 54, 40, 35, 69, 33, 57, 96, 17,
//      82, 49,  1, 18,  7, 28, 47, 59, 66, 90,  9, 25,
//      93, 92, 26, 55, 23, 85, 62, 21, 98, 48, 56, 50,
//      30, 46, 63, 24, 27, 73, 84, 43, 87, 80, 14, 78,
//      95, 74, 52, 91, 67, 31, 16, 11, 94,  2, 22, 51,
//      71, 99,  5, 61, 72, 83, 19, 36, 86, 45, 15, 70,
//      42, 34, 53, 79
//   ] [
//     100000, 50000, 10000, 10000, 10000, 10000, 5000, 5000, 5000,
//       5000,  5000,  5000,  5000,  5000,  5000, 5000, 1000, 1000,
//       1000,  1000,  1000,  1000,  1000,  1000, 1000, 1000, 1000,
//       1000,  1000,  1000,  1000,  1000,  1000, 1000, 1000, 1000,
//        500,   500,   500,   500,   500,   500,  500,  500,  500,
//        500,   500,   500,   500,   500,   500,  500,  500,  500,
//        500,   500,   500,   500,   500,   500,  500,  500,  500,
//        500,   500,   500,   100,   100,   100,  100,  100,  100,
//        100,   100,   100,   100,   100,   100,  100,  100,  100,
//        100,   100,   100,   100,   100,   100,  100,  100,  100,
//        100,   100,   100,   100,   100,   100,  100,  100,  100,
//        100
//   ] [
//     8, 8, 3,  7,  6, 4,  7, 1, 10,  2, 7, 4,
//     2, 6, 3,  3,  6, 3,  8, 4,  4,  9, 1, 4,
//     3, 9, 3,  1,  5, 7,  1, 7,  5, 10, 4, 8,
//     5, 2, 7,  8,  1, 1, 10, 9,  5,  2, 9, 7,
//     9, 2, 8,  6, 10, 1,  3, 4,  6, 10, 6, 4,
//     7, 8, 9,  6,  3, 4,  4, 6, 10,  6, 7, 6,
//     3, 1, 6,  5,  2, 5,  5, 7,  3,  1, 8, 5,
//     5, 6, 2, 10,  9, 5,  9, 2,  4,  1, 6, 1,
//     5, 4, 1,  6
//   ]

const { generateImages } = require("./imglib.js")
const prizes = 
[
    {
        prize: 100000, // 100000
        amount: 1,
        winners: [],
    },
    {
        prize: 50000, // 50000
        amount: 1,
        winners: [],
    },
    {
        prize: 10000,// 40000
        amount: 4,
        winners: [],
    },
    {
        prize: 5000, // 50000
        amount: 10,
        winners: [],
    },
    {
        prize: 1000, // 20000
        amount: 20,
        winners: [],
    },
    {
        prize: 500, // 15000
        amount: 30,
        winners: [],
    },
    {
        prize: 100, // 3000
        amount: 30,
        winners: [],
    },
    {
        prize: 100,  // 1000
        amount: 4,
        winners: [],
    }
]

// 279000 total prizes

function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1)); // Generate a random index between 0 and i
      [array[i], array[j]] = [array[j], array[i]]; // Swap elements at i and j
    }
  }
  
const getRandomTicketFromArrayAndRemove = (arr) => {
    const randomIndex = Math.floor(Math.random() * arr.length);
    let result = arr[randomIndex];
    arr.splice(randomIndex, 1);
    return result;
  }

const designPrize = () => {
   let ticketCount = 100;
   let ticketArray = [];
    
   for(i=1; i<ticketCount + 1; i++) {
    ticketArray.push(i)
   }

   prizes.forEach(prize => {
        // get random position from array;
        // remove that position from the array
        for(p=0; p<prize.amount; p++) {
            if(ticketArray.length > 0) {
                prize.winners.push(getRandomTicketFromArrayAndRemove(ticketArray));
            }
        }
   })

   let winArray = []

   prizes.forEach(prize => {
        prize.winners.forEach(winner => {

            // choose random edition
            let edition = (Math.floor(Math.random() * (10)) + 1);
            // we need to get 8 numbers on the tickets

            let numbers = [];
            // first push the 3 numbers to array
            for(let i=0; i<3; i++) {
                numbers.push(prize.prize.toString());
            }
            // for the remaining 5 numbers get 5 unique other numbers
            let possibilities = [100, 100, 500, 500, 1000, 1000, 5000, 5000, 10000, 100000, 100000];
            // remove numbers we already have
            let idx = possibilities.indexOf(prize.prize);
            possibilities.splice(idx, 2);

            for(let i=0; i<5; i++) {
                let randomIndex = Math.floor(Math.random() * possibilities.length);
                numbers.push(possibilities[randomIndex].toString())
                possibilities.splice(randomIndex, 1);
            }

            shuffleArray(numbers)
            winArray.push({id: winner, prize: prize.prize, numbers, edition})

        })
   })




   generateImages(winArray)
   // after contract deployment set the prizes to match the images
   // need to update chainlink VRF consumer!!
   let k = []
   let v = []
   let e = []
   winArray.forEach(val => {
    k.push(val.id), v.push(val.prize) , e.push(val.edition)
    // random number between 1 and 10
    })
    console.log(k, v, e)


}

designPrize();