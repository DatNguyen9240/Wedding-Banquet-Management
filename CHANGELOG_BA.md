CHANGELOG BA - Wedding Banquet Management System

IMPLEMENTATION AUDIT SUMMARY — Reconstructed 2026-08-28

Important: The uploaded file still contained PENDING SOURCE AUDIT for all 40 requirements.
The status values below were reconstructed from the completed Kilo audit results already produced in this conversation.

Detailed source-code evidence was not persisted in the uploaded file.
Therefore these statuses are useful for planning, but they should not be treated as final implementation proof until the relevant source evidence/file paths are captured.

Status Summary

Status

Count

Requirement IDs

CONFIRMED

0

None

PARTIAL

6

REQ-02, REQ-03, REQ-04, REQ-17, REQ-19, REQ-27

MISSING

33

REQ-01, REQ-05, REQ-06, REQ-07, REQ-08, REQ-09, REQ-10, REQ-11, REQ-13, REQ-14, REQ-15, REQ-16, REQ-18, REQ-20, REQ-21, REQ-22, REQ-23, REQ-24, REQ-25, REQ-26, REQ-28, REQ-29, REQ-30, REQ-31, REQ-32, REQ-33, REQ-34, REQ-35, REQ-36, REQ-37, REQ-38, REQ-39, REQ-40

MISMATCH

0

None

NEEDS_CLARIFICATION

1

REQ-12

NOT_VERIFIABLE

0

None

Total requirements: 40

Audit Integrity Note

REQ-01 through REQ-40 are present.

The original file had not actually persisted the Kilo audit statuses; each Verification still said PENDING SOURCE AUDIT.

This corrected copy updates every Verification block with the status reported during the batch audits.

No Current Implementation, Source Evidence, Gap, or Recommended Action details were invented.

Before implementation begins, any requirement selected for coding should have its source evidence re-verified and written into this file.

A. DOCUMENT EXPORT & SETTLEMENT

REQ-01 - Xuất DOCX Hợp đồng / Phiếu thu / BEO

Requirement

Khách hàng phản ánh chức năng xuất DOCX để kiểm tra các tài liệu sau hiện không hoạt động đúng:

Hợp đồng

Phiếu thu

BEO

Cần đảm bảo cả 3 loại tài liệu có thể được xuất DOCX thành công với đúng dữ liệu.

Verification

Status: MISSING

Audit Notes

Cần kiểm tra:

frontend trigger export

API/service export

template mapping

file generation

download response

dữ liệu truyền vào template

---

REQ-02 - Hai mẫu Quyết toán khác nhau

Requirement

Hệ thống có 2 mẫu quyết toán:

QUYẾT TOÁN 01

Dành cho các loại tiệc cá nhân như:

tiệc cưới

báo hỷ

sinh nhật

mừng thọ

thôi nôi

các loại tiệc tương tự

QUYẾT TOÁN 02

Dành cho khách hàng pháp nhân / tổ chức như:

công ty

sự kiện

hội nghị

triển lãm

hội thảo

các loại hình tương tự

Hệ thống phải chọn đúng mẫu quyết toán theo loại khách hàng / loại sự kiện.

Verification

Status: PARTIAL

---

REQ-03 - Menu có hai hình thức

Requirement

Menu phải hỗ trợ hai hình thức:

1. Menu theo set

2. Menu tự chọn món

Hai hình thức phải được phân biệt rõ trong nghiệp vụ và dữ liệu.

Verification

Status: PARTIAL

---

REQ-04 - Set menu được đổi món và tính bù giá

Requirement

Với hình thức set menu:

khách vẫn được đổi món nằm trong set

món mới có thể có đơn giá khác món cũ

nếu có chênh lệch giá thì hệ thống phải ghi nhận phần bù giá theo món

Verification

Status: PARTIAL

Audit Notes

Cần kiểm tra:

cấu trúc set menu

replace/swap item

price difference

cách tính tổng

cách đưa dữ liệu sang BEO / Quyết toán

---

REQ-05 - Ghi nhận phát sinh trong tiệc

Requirement

Trong quá trình diễn ra tiệc có thể phát sinh thêm dịch vụ / hàng hóa / chi phí.

Hệ thống cần cho phép ghi nhận các phát sinh thực tế này để sử dụng trong bước quyết toán.

Verification

Status: MISSING

---

REQ-06 - Quyết toán lấy dữ liệu từ BEO cuối cùng

Requirement

Quyết toán tiệc phải lấy dữ liệu từ:

1. BEO sau lần thay đổi cuối cùng

2. cộng thêm các phát sinh thực tế trong tiệc

Không nên chỉ sử dụng dữ liệu của hợp đồng ban đầu.

Verification

Status: MISSING

Audit Notes

Phải trace:

Contract -> Menu -> BEO -> Final BEO -> Event Actuals -> Settlement

Đây là requirement liên quan workflow, không chỉ liên quan template.

---

B. DECORATION

REQ-07 - Mẫu trang trí không được mặc định sẵn

Requirement

Mẫu trang trí không được hard-code hoặc mặc định một mẫu cố định.

Cần có danh mục / thư viện hình ảnh các mẫu trang trí để người dùng:

xem mẫu

lựa chọn

tick/chọn mẫu phù hợp cho từng hợp đồng

Verification

Status: MISSING

---

C. EXHIBITION + BANQUET CONTRACT

REQ-08 - Triển lãm và tiệc sử dụng địa điểm riêng

Requirement

Trong Hợp đồng Triển lãm + Tiệc:

địa điểm triển lãm: chọn 1 sảnh

địa điểm tiệc: chọn 1 sảnh

Hai địa điểm có thể khác nhau.

Verification

Status: MISSING

Important

Diamond / Ruby trong tài liệu chỉ là dữ liệu ví dụ.

Không được hard-code Diamond hoặc Ruby.

---

REQ-09 - Tiệc có thể là trưa hoặc tối

Requirement

Trong Hợp đồng Triển lãm + Tiệc:

Phần tiệc có thể là:

tiệc trưa

hoặc tiệc tối

Không được mặc định cứng một loại / thời điểm.

Verification

Status: MISSING

---

REQ-10 - Số hợp đồng không mặc định sẵn

Requirement

Số hợp đồng không được hard-code hoặc sinh ra dưới dạng một giá trị mặc định sai nghiệp vụ.

Cần để hệ thống xử lý theo đúng quy trình thực tế:

nhập tay

hoặc sinh theo nghiệp vụ thực tế nếu source hiện tại đã có rule phù hợp

Verification

Status: MISSING

Clarification

Cần Source Audit trước để xác định số hợp đồng hiện:

nhập tay

auto-generate

hay đang bị hard-code trong template.

---

D. HALL / VENUE PRICING

REQ-11 - Thuê sảnh phát sinh lấy giá từ Danh mục Sảnh

Requirement

Mục:

Thuê sảnh phát sinh ngoài thời gian hợp đồng

không được hard-code đơn giá trong hợp đồng.

Đơn giá phải lấy từ dữ liệu của Danh mục Sảnh.

Verification

Status: MISSING

---

REQ-12 - Giá thuê sảnh được quản lý theo buổi 4 tiếng

Requirement

Khách hàng mô tả giá thuê sảnh được quản lý theo:

1 buổi = 4 tiếng

Đối với phát sinh ngoài thời gian hợp đồng, giá phát sinh cần dựa trên giá trong Danh mục Sảnh.

Verification

Status: NEEDS_CLARIFICATION

Clarification Required

Cần xác nhận chính xác công thức:

đơn giá phát sinh theo giờ = giá một buổi / 4

hay có thêm rule khác.

Không được tự giả định công thức trước khi kiểm tra source / hỏi lại khách.

---

E. EXHIBITION CONTRACT

REQ-13 - Có mẫu Hợp đồng Triển lãm riêng

Requirement

Cần hỗ trợ mẫu Hợp đồng Triển lãm riêng.

Wording phải thể hiện đúng nghiệp vụ:

Bên B có nhu cầu thuê địa điểm để tổ chức triển lãm

Bên A đồng ý cung cấp dịch vụ cho thuê địa điểm theo yêu cầu của Bên B

Không được dùng wording của Hợp đồng Triển lãm + Tiệc nếu hợp đồng chỉ có triển lãm.

Verification

Status: MISSING

---

REQ-14 - Thông tin sự kiện của Hợp đồng Triển lãm

Requirement

Hợp đồng Triển lãm cần hỗ trợ nhập các thông tin như:

Loại hình tổ chức: Triển lãm

Địa điểm triển lãm

Số lượng khách tham quan dự kiến

thời gian setup

thời gian triển lãm

các dữ liệu liên quan khác

Các giá trị phải theo từng hợp đồng thực tế.

Verification

Status: MISSING

Important

Không được lấy số khách / sảnh trong tài liệu mẫu làm default.

---

REQ-15 - Không lặp kích thước sân khấu trong DOCX

Requirement

Trong tài liệu xuất hiện tại có trường hợp thông tin kích thước sân khấu bị thể hiện lặp 2 lần.

Khi xuất tài liệu:

kích thước sân khấu chỉ được hiển thị đúng một lần

đúng dữ liệu thực tế

Verification

Status: MISSING

---

F. DEPOSIT / CONTRACT PAYMENT

REQ-16 - Khách pháp nhân ký hợp đồng rồi mới chuyển cọc

Requirement

Đối với khách hàng là pháp nhân:

Quy trình nghiệp vụ là:

Hoàn thiện / ký hợp đồng -> Chuyển tiền cọc

Không nên mặc định cọc ngay từ bước nhập thông tin ban đầu nếu chưa tới bước nghiệp vụ phù hợp.

Verification

Status: MISSING

---

REQ-17 - Không mặc định cọc 70%

Requirement

Không mặc định tiền cọc bằng:

70% giá trị hợp đồng tạm tính

Tỷ lệ / số tiền cọc phải có khả năng thay đổi theo thỏa thuận thực tế với khách.

Ví dụ khách có thể deal:

40%

30%

hoặc giá trị khác

Verification

Status: PARTIAL

Audit Notes

Trace:

UI deposit input -> contract data -> calculation -> payment schedule -> DOCX

---

G. INVOICE / CONTACT INFORMATION

REQ-18 - Nội dung xuất hóa đơn không được hard-code sai nghiệp vụ

Requirement

Phần nội dung xuất hóa đơn cần được kiểm tra để tránh việc hard-code dữ liệu không phù hợp với từng hợp đồng.

Verification

Status: MISSING

Clarification Required

Ảnh hiện tại chưa đủ để xác định khách muốn:

mở toàn bộ nội dung xuất hóa đơn cho nhập tay

hay chỉ mở một số trường như số hợp đồng / ngày / nội dung tham chiếu.

Không được tự giả định trước khi audit.

---

REQ-19 - Người phụ trách giao dịch và chức vụ được nhập linh hoạt

Requirement

Trong phần:

Thông tin liên lạc và đầu mối thực hiện hợp đồng

các trường:

Người phụ trách giao dịch

Chức vụ

phải có khả năng nhập theo từng hợp đồng.

Không nên hard-code:

Giám đốc

hoặc một người cố định

Thông thường có thể là nhân viên phòng kinh doanh.

Verification

Status: PARTIAL

---

H. CONFERENCE + BANQUET CONTRACT

REQ-20 - Đúng wording Hội nghị + Tiệc

Requirement

Trong Hợp đồng Hội nghị + Tiệc:

Các nội dung đang sử dụng từ "triển lãm" sai ngữ cảnh phải được thay thành "hội nghị".

Ví dụ:

tổ chức hội nghị và tiệc

địa điểm hội nghị

thời gian hội nghị

Verification

Status: MISSING

---

REQ-21 - Setup bàn ghế hội nghị chọn từ danh sách

Requirement

Mục setup bàn ghế hội nghị không được chỉ là một text hard-code.

Người dùng phải có khả năng chọn kiểu setup từ danh sách được hệ thống quản lý.

Verification

Status: MISSING

---

REQ-22 - Setup bàn tiệc chọn từ danh sách

Requirement

Mục setup bàn tiệc cũng phải cho phép chọn theo danh sách.

Không được hard-code một kiểu setup bàn tiệc cố định.

Verification

Status: MISSING

---

REQ-23 - Địa điểm hội nghị và địa điểm tiệc độc lập

Requirement

Trong Hợp đồng Hội nghị + Tiệc:

địa điểm hội nghị là một thông tin riêng

địa điểm tiệc là một thông tin riêng

Tiệc có thể diễn ra:

buổi trưa

hoặc buổi tối

Không được mặc định cứng.

Verification

Status: MISSING

---

I. SHARED RULES ACROSS CONTRACT TEMPLATES

REQ-24 - Đổi wording "Quyết toán tiệc" thành "Quyết toán dịch vụ"

Requirement

Trong phần hồ sơ thanh toán:

Cụm:

"Biên bản nghiệm thu và quyết toán tiệc"

phải được sửa thành:

"Biên bản nghiệm thu và quyết toán dịch vụ"

ở các mẫu áp dụng cho dịch vụ / sự kiện tương ứng.

Verification

Status: MISSING

---

REQ-25 - Đồng bộ rule thuê sảnh phát sinh cho các hợp đồng

Requirement

Các hợp đồng khác có mục:

Thuê sảnh phát sinh ngoài thời gian hợp đồng

phải áp dụng cùng business rule đã mô tả tại REQ-11 / REQ-12.

Verification

Status: MISSING

Audit Instruction

Không viết lại logic nếu một template khác đã có implementation đúng.

Tìm implementation có thể tái sử dụng trước.

---

REQ-26 - Đồng bộ rule đặt cọc cho các hợp đồng

Requirement

Phần cọc thực hiện hợp đồng ở các mẫu hợp đồng liên quan phải áp dụng cùng business rule:

không mặc định 70%

tỷ lệ / số tiền cọc theo thỏa thuận

đúng thời điểm trong workflow

Verification

Status: MISSING

Related Requirements

REQ-16

REQ-17

---

REQ-27 - Đồng bộ thông tin đầu mối liên lạc

Requirement

Phần:

Thông tin liên lạc và đầu mối thực hiện hợp đồng

ở các mẫu hợp đồng liên quan phải áp dụng cùng rule:

người phụ trách giao dịch linh hoạt

chức vụ linh hoạt

thông tin liên hệ lấy từ dữ liệu thực tế

không hard-code sai

Verification

Status: PARTIAL

Related Requirement

REQ-19

---

J. CONFERENCE CONTRACT

REQ-28 - Mẫu Hợp đồng Hội nghị dùng đúng wording

Requirement

Mẫu Hợp đồng Hội nghị riêng phải sử dụng đúng wording.

Ví dụ:

"Sau khi bàn bạc, hai bên cùng thống nhất ký Hợp đồng hội nghị..."

và:

"Bên B có nhu cầu thuê địa điểm để tổ chức hội nghị và Bên A đồng ý cung cấp dịch vụ cho thuê địa điểm..."

Không được còn nội dung "triển lãm" do copy template.

Verification

Status: MISSING

---

REQ-29 - Setup bàn ghế Hợp đồng Hội nghị chọn từ danh sách

Requirement

Trong Hợp đồng Hội nghị:

Mục setup bàn ghế phải áp dụng cùng rule với REQ-21:

chọn từ danh sách

không hard-code text cố định

Verification

Status: MISSING

---

REQ-30 - Đồng bộ cọc / thanh toán / hóa đơn giữa các hợp đồng

Requirement

Các mẫu hợp đồng pháp nhân / sự kiện cần áp dụng cùng business rules đối với:

cọc thực hiện hợp đồng

hình thức thanh toán

thông tin xuất hóa đơn GTGT

Không nên có mỗi template một logic khác nhau nếu nghiệp vụ thực tế là giống nhau.

Verification

Status: MISSING

Related Requirements

REQ-16

REQ-17

REQ-18

REQ-26

---

K. WEDDING CONTRACT BUSINESS RULES

REQ-31 - Bàn vượt 10% tính thêm 10%, không phải 15%

Requirement

Trong điều khoản về số bàn thực tế vượt quá số lượng bàn chính thức:

Nếu phần bàn vượt quá ngưỡng 10% theo điều khoản hợp đồng thì đơn giá phần bàn vượt phải được tính:

đơn giá bàn tiệc chính thức + 10%

Không phải:

+15%

Verification

Status: MISSING

Audit Notes

Kiểm tra cả:

business calculation

contract wording

DOCX output

Không chỉ sửa text nếu source có calculation tương ứng.

---

REQ-32 - Phí phục vụ phải configurable

Requirement

Phí phục vụ không được hard-code cố định.

Phải có khả năng:

áp phí

giảm phí

hoặc miễn phí

tùy chương trình khuyến mãi / giai đoạn bán hàng.

Verification

Status: MISSING

---

L. PROMOTIONS

REQ-33 - CTKM chọn từ danh mục đang áp dụng

Requirement

Phần chương trình khuyến mãi đính kèm hợp đồng phải cho phép chọn từ:

Danh mục CTKM đang áp dụng

Thay vì hard-code nội dung khuyến mãi cố định.

CTKM có thể liên quan đến số bàn đủ điều kiện / số bàn chuyển qua.

Verification

Status: MISSING

Audit Notes

Cần kiểm tra xem source đã có module Promotion / CTKM hay chưa.

Nếu đã có, ưu tiên reuse thay vì tạo hệ thống mới.

---

REQ-34 - Điều khoản bổ sung nhập theo từng hợp đồng

Requirement

Phần:

Các điều khoản bổ sung

phải cho phép nhập tay theo từng hợp đồng.

Không nên hard-code một nội dung cố định cho tất cả khách hàng.

Verification

Status: MISSING

---

REQ-35 - Câu cuối CTKM là nội dung cố định

Requirement

Khách xác nhận câu cuối bắt đầu bằng:

"Tất cả CTKM..."

là nội dung cố định của template.

Không cần biến câu này thành trường nhập tay.

Verification

Status: MISSING

---

M. CONTRACT APPENDIX

REQ-36 - Phụ lục hợp đồng phải có số

Requirement

Phụ lục hợp đồng phải có thông tin:

Số: ...

Không được bị thiếu / bỏ trống ngoài ý muốn.

Verification

Status: MISSING

Clarification Required

Cần audit / xác nhận số phụ lục:

nhập tay

auto-generate

hay sinh theo số hợp đồng.

---

REQ-37 - Bổ sung đầy đủ thông tin số bàn

Requirement

Khách phản ánh phần Hợp đồng / Phụ lục tiệc cưới đang thiếu thông tin liên quan đến số bàn.

Cần đảm bảo các thông tin số bàn cần thiết được thể hiện đầy đủ.

Verification

Status: MISSING

Clarification Required

Cần xác định chính xác scope bao gồm:

số bàn chính thức

số bàn tặng

số bàn dự phòng

hoặc các loại bàn khác.

Không được tự giả định trước khi audit source.

---

N. MENU REQUIREMENTS

REQ-38 - Một hợp đồng có thể có cả menu mặn và menu chay

Requirement

Phần thực đơn phải hỗ trợ trường hợp một hợp đồng / tiệc có đồng thời:

thực đơn mặn

thực đơn chay

Không được giới hạn chỉ một loại menu.

Verification

Status: MISSING

Audit Notes

Kiểm tra:

data model

UI

menu selection

price calculation

DOCX / Phụ lục / BEO

---

O. ADDITIONAL WEDDING CONTRACT TEMPLATE

REQ-39 - Thiếu mẫu hợp đồng tiệc cưới chọn ngay menu trong vòng 30 ngày

Requirement

Khách phản ánh hiện đang thiếu một mẫu:

Hợp đồng tiệc cưới chọn ngay menu

Áp dụng cho trường hợp:

Từ ngày cọc đến ngày diễn ra tiệc trong vòng 30 ngày.

Verification

Status: MISSING

Audit Notes

Cần kiểm tra source trước để xác nhận:

template thật sự chưa tồn tại

hay đã tồn tại nhưng chưa được expose / chọn trên UI.

---

P. COMPANY / PARTY INFORMATION

REQ-40 - Chỉnh địa chỉ bên hợp đồng trên tất cả mẫu

Requirement

Khách phản ánh địa chỉ của một bên trong hợp đồng hiện đang sai.

Cần chỉnh dữ liệu địa chỉ đúng và đảm bảo áp dụng nhất quán trên tất cả mẫu hợp đồng liên quan.

Verification

Status: MISSING

Clarification Required

Cần xác định chính xác:

bên nào đang sai địa chỉ

địa chỉ đúng là gì

địa chỉ lấy từ cấu hình công ty hay đang hard-code trong template.

Không chỉnh địa chỉ trước khi xác nhận nguồn dữ liệu đúng.

---

SOURCE AUDIT STATUS LEGEND

Sau khi audit source, mỗi requirement phải được phân loại bằng đúng một trạng thái:

CONFIRMED

Source hiện tại đã đáp ứng đúng requirement.

PARTIAL

Đã có implementation nhưng chưa đầy đủ.

MISSING

Không tìm thấy implementation sau khi đã search đầy đủ source.

MISMATCH

Đã có implementation nhưng hành vi hiện tại khác yêu cầu khách hàng.

NEEDS_CLARIFICATION

Không đủ thông tin nghiệp vụ để quyết định hành vi đúng.

NOT_VERIFIABLE

Repository hiện tại không cung cấp đủ bằng chứng để xác minh.

---

SOURCE AUDIT FORMAT

Khi audit từng requirement, bổ sung phần sau ngay bên dưới Verification:

Source Audit

Status: CONFIRMED / PARTIAL / MISSING / MISMATCH / NEEDS_CLARIFICATION / NOT_VERIFIABLE

Current Implementation:

Mô tả hành vi hiện tại của source.

Source Evidence:

path/to/file

  - Class / Function / Component:

  - Evidence:

Data Flow:

Nếu có:

UI -> Service -> Calculation -> Template

Gap:

Mô tả điểm khác biệt giữa source hiện tại và requirement.

Existing Reusable Implementation:

Nếu một contract/template/module khác đã có đúng logic, ghi rõ ở đây.

Recommended Action:

Chọn một:

NO CHANGE

SMALL FIX

TEMPLATE FIX

BUSINESS LOGIC CHANGE

DATA MODEL CHANGE

NEED CUSTOMER CLARIFICATION

---

UNRESOLVED CUSTOMER NOTES

Các ghi chú sau xuất hiện trong trao đổi nhưng chưa đủ dữ liệu để nâng thành một requirement độc lập:

U-01 - An toàn lao động / an toàn kỹ thuật / PCCC

Khách có highlight phần:

an toàn lao động

an toàn kỹ thuật

PCCC

nhưng chưa chỉ rõ yêu cầu cần:

sửa wording

thêm nội dung

bỏ nội dung

hay chỉ kiểm tra lại.

Không sửa phần này cho đến khi có thêm thông tin.

---

AUDIT SUMMARY

| Group | Requirements |

|---|---:|

| Document Export / Settlement | REQ-01 -> REQ-06 |

| Decoration | REQ-07 |

| Exhibition + Banquet | REQ-08 -> REQ-10 |

| Hall Pricing | REQ-11 -> REQ-12 |

| Exhibition Contract | REQ-13 -> REQ-15 |

| Deposit / Payment | REQ-16 -> REQ-17 |

| Invoice / Contact | REQ-18 -> REQ-19 |

| Conference + Banquet | REQ-20 -> REQ-23 |

| Shared Contract Rules | REQ-24 -> REQ-27 |

| Conference Contract | REQ-28 -> REQ-30 |

| Wedding Business Rules | REQ-31 -> REQ-32 |

| Promotions | REQ-33 -> REQ-35 |

| Contract Appendix | REQ-36 -> REQ-37 |

| Menu | REQ-38 |

| Additional Wedding Template | REQ-39 |

| Company / Party Information | REQ-40 |

Total normalized requirements: 40

Source audit status classification completed: YES (40/40)

Detailed source evidence persisted in this file: NO

Implementation approved: NO

DO NOT IMPLEMENT UNTIL SOURCE AUDIT IS REVIEWED.

RECONSTRUCTED AUDIT STATUS MAP

PARTIAL (6)

REQ-02, REQ-03, REQ-04, REQ-17, REQ-19, REQ-27

NEEDS_CLARIFICATION (1)

REQ-12

MISSING (33)

REQ-01, REQ-05, REQ-06, REQ-07, REQ-08, REQ-09, REQ-10, REQ-11, REQ-13, REQ-14, REQ-15, REQ-16, REQ-18, REQ-20, REQ-21, REQ-22, REQ-23, REQ-24, REQ-25, REQ-26, REQ-28, REQ-29, REQ-30, REQ-31, REQ-32, REQ-33, REQ-34, REQ-35, REQ-36, REQ-37, REQ-38, REQ-39, REQ-40

ZERO COUNT

CONFIRMED: 0

MISMATCH: 0

NOT_VERIFIABLE: 0

These classifications were reconstructed from prior audit outputs. Detailed source evidence is not present in this file.

