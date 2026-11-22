# Bật lưu dữ liệu trên cloud cho Word Farm (Supabase)

Khi bật, phụ huynh đăng nhập bằng email. Hồ sơ, tiến độ học, khu vườn và ảnh tự tải lên của các bé được lưu trên cloud và tự đồng bộ giữa các thiết bị. Không đăng nhập thì trang vẫn chạy như cũ, chỉ lưu trên máy.

Làm một lần, mất khoảng 15 phút.

## 1. Tạo project Supabase

1. Vào https://supabase.com, đăng nhập rồi bấm **New project**.
2. Đặt tên, ví dụ `word-farm`, chọn khu vực gần Việt Nam (ví dụ **Southeast Asia (Singapore)**) và đặt mật khẩu cơ sở dữ liệu. Mật khẩu này chỉ để bạn giữ, không cần dán vào trang.
3. Đợi khoảng 1–2 phút cho project tạo xong.

Nên dùng project riêng cho Word Farm, không dùng chung với project thu chi.

## 2. Tạo bảng và quy tắc bảo mật

1. Trong project, mở **SQL Editor** rồi bấm **New query**.
2. Mở file `supabase-setup.sql` (nằm cạnh file này), chép toàn bộ nội dung, dán vào ô truy vấn rồi bấm **Run**.
3. Thấy dòng "Success" là xong. File này tạo:
   - bảng `children`, mỗi bé là một dòng;
   - kho ảnh riêng tư `photos`;
   - quy tắc bảo mật: mỗi tài khoản chỉ đọc và sửa được dữ liệu của chính mình.

## 3. Cài đặt đăng nhập bằng email

1. Mở **Authentication → URL Configuration**.
   - **Site URL**: địa chỉ trang Word Farm sau khi đưa lên web, ví dụ `https://word-farm.netlify.app`.
   - **Redirect URLs**: thêm địa chỉ đó. Nếu muốn thử trên máy thì thêm cả `http://localhost:5180`.
2. Mở **Authentication → Emails → Magic Link** (tên mục có thể hơi khác tùy phiên bản giao diện). Thêm dòng sau vào nội dung email để phụ huynh nhận cả mã 6 số, tiện khi đọc email trên một máy và học trên máy khác:

   ```
   <p>Or type this code in Word Farm: <b>{{ .Token }}</b></p>
   ```

3. Email mặc định của Supabase chỉ gửi được vài thư mỗi giờ. Dùng trong gia đình thì đủ. Nếu nhiều gia đình cùng dùng, vào **Authentication → Emails → SMTP Settings** để nối với một dịch vụ gửi mail như Resend hoặc Brevo (đều có gói miễn phí).

## 4. Dán địa chỉ và khóa vào trang

1. Mở **Project Settings → API** (hoặc **Data API / API Keys**).
2. Chép **Project URL** và khóa **anon / public**.
3. Mở `index.html`, tìm đoạn này ở đầu phần mã rồi dán vào:

   ```js
   const SUPABASE_URL = 'https://xxxxxxxx.supabase.co';
   const SUPABASE_ANON_KEY = 'eyJhbGciOi...';
   ```

Khóa **anon** được phép nằm trong trang web: quy tắc bảo mật ở bước 2 đã chặn ngay ở cơ sở dữ liệu. **Tuyệt đối không** dán khóa `service_role` hay `secret` vào trang, vì khóa đó bỏ qua mọi quy tắc bảo mật.

## 5. Đưa trang lên web và dùng thử

1. Đưa thư mục `hoc-tu-vung` lên web, ví dụ kéo thả vào https://app.netlify.com/drop. Nếu địa chỉ khác với bước 3 thì quay lại sửa Site URL.
2. Mở trang, vào **Parents' area → Cloud sync**, nhập email rồi bấm **Send sign-in email**.
3. Bấm link trong email trên cùng máy đó, hoặc gõ mã 6 số vào trang.
4. Lần đăng nhập đầu tiên, các bé đang có trên máy được đẩy lên cloud.
5. Trên máy thứ hai, mở trang rồi bấm **☁️ Sign in to load your children**. Các bé sẽ hiện ra.

## Cách đồng bộ hoạt động

- Máy nào cũng giữ một bản trên máy, nên vẫn học được khi mất mạng.
- Mỗi thay đổi được đẩy lên cloud sau khoảng 5 giây. Khi mở trang hoặc quay lại trang, máy tự tải bản mới hơn từ máy khác về.
- Nếu hai máy cùng thay đổi một bé trước khi kịp đồng bộ, **bản lưu sau cùng được giữ**, bản kia bị thay thế. Vì vậy mỗi bé nên học trên một máy tại một thời điểm.
- Xóa một bé ở một máy thì bé đó cũng bị xóa ở các máy khác.
- **Sign out on this device** xóa dữ liệu khỏi máy đó; dữ liệu vẫn còn trên cloud.
- Biểu tượng ở góc trên: ☁️ đã lưu · 🔄 đang lưu · 📴 mất mạng, sẽ lưu sau · ⚠️ có lỗi (xem chi tiết trong Parents' area).

## Nên biết

- Project Supabase miễn phí tự **tạm dừng nếu 7 ngày liền không ai dùng**. Vào bảng điều khiển Supabase bấm **Restore** là chạy lại, dữ liệu vẫn còn.
- Gói miễn phí có 500 MB cơ sở dữ liệu và 1 GB lưu ảnh, đủ cho rất nhiều gia đình.
- Đây là dữ liệu về trẻ em, nên chỉ dùng tên gọi ở nhà. Trang chỉ lưu tên, con vật đại diện, các từ đã học, tiến độ và ảnh do bé tự tải lên.
- Muốn xóa hẳn tài khoản của một gia đình: vào **Authentication → Users**, xóa người dùng đó. Dữ liệu các bé của tài khoản đó tự xóa theo. Riêng ảnh thì vào **Storage → photos** và xóa thư mục mang mã của người dùng đó.
