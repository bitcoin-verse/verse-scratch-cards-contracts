// [
//     70, 100, 60, 20,  4, 43, 66, 65, 13, 18, 14, 16,
//     64,   5, 83, 31, 22, 42,  6, 39, 11, 10, 80, 12,
//     35,  78,  3, 44, 72, 86, 52, 32, 51, 37, 19,  2,
//     50,  25, 92, 69, 41, 67, 90, 36, 91, 34, 95, 84,
//     28,  85, 27, 93, 58, 88, 79, 30, 24, 94, 71, 63,
//     23,  77, 48,  9, 46, 57, 75, 68, 53, 81,  1, 82,
//     74,  40, 15, 17, 21, 54, 98, 55, 56, 76, 49,  8,
//     33,  26,  7, 45, 96, 87, 61, 62, 73, 99, 97, 47,
//     29,  89, 59, 38
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
//      5,  3,  3, 1, 8, 7,  4, 1, 7, 10, 10, 4,
//      6, 10,  9, 6, 3, 1, 10, 8, 3,  9,  9, 7,
//      7,  1,  7, 5, 4, 6, 10, 5, 8,  8,  2, 3,
//     10, 10,  2, 7, 4, 2,  8, 2, 3,  4,  9, 7,
//      2,  1,  3, 3, 4, 8, 10, 5, 9,  7,  3, 2,
//      4,  5, 10, 4, 8, 2,  2, 3, 7,  6,  2, 9,
//      8,  8, 10, 7, 6, 2,  1, 9, 8, 10,  8, 7,
//      4,  6,  4, 1, 3, 2,  8, 4, 8,  4,  6, 6,
//      6,  3,  6, 6
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
            let possibilities = [100, 100, 500, 500, 1000, 1000, 5000, 5000, 10000, 10000, 50000, 50000, 100000, 100000];
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