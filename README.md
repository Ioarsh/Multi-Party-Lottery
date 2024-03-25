# Multi-Party Lottery in Solidity
## หลักการ
ใช้ต้นแบบมาจาก RWAPSSF ซึ่ง จะใช้ Struct player และ CommitReveal.sol มาจาก HW3 เป็น BASE ในการสร้าง โดยผู้เล่นแต่ละคนจะมี Struct เป็นของตัวเอง และมี mapping จาก address ไป index และ mapping จาก index ไป Struct
## การทำงาน
จะแบ่งเป็น 4 Stage ซึ่งแต่ละ Stage จะมีเวลทำงานของมัน
### ฟังก์ชันที่สำคัญของ Stage 1
มีฟังก์ชัน addPlayer() ที่จะทำการรับค่า Transaction และ Salt ของผู้เล่นมา และทำการ Hash , Commit ไปในตัว
### ฟังก์ชันที่สำคัญของ Stage 2
มีฟังก์ชัน RevealAns() ที่จะทำการเปิดเผยค่า Transaction และเป็นการยืนยันว่าจะเข้าร่วมการเล่น lottery
### ฟังก์ชันที่สำคัญของ Stage 3
checkWinnerAndPay() จะทำการหาผู้ชนะ lottery โดยจะเริ่มการสุ่มค่าก่อนแล้วค่อยใช้ XOR เพื่อหาผู้ชนะ แล้วจึงจ่ายเงินตามที่ได้กำหนด
### ฟังก์ชันที่สำคัญของ Stage 4
withdraw() จะถอนเงินที่ได้ลงไปในตอนแรก ในกรณีที่ owner ไม่ทำการกด checkWinnerAndPay() เพื่อให้เป็นธรรมแก่ผู้เล่น และเมื่อทุกคนถอนหมดแล้วจะมี auto_reset เพื่อล้างค่าไปใช้เล่นในตาต่อๆไป
### ฟังก์ชันที่สำคัญอื่นๆ
มีการ force_reset ซึ่ง owner จะสามารถกดได้เท่านั้น ในกรณีที่ผู้เล่นไม่ยอม withdraw() เงินของตัวเองคืน เพื่อจะได้เล่นในรอบถัดไป