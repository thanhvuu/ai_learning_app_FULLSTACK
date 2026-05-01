package com.vu.ai_learning_backend.controller;

import com.vu.ai_learning_backend.entity.User;
import com.vu.ai_learning_backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.mindrot.jbcrypt.BCrypt;

import java.util.List;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Map;

@RestController // Khai báo đây là đầu mối API
@CrossOrigin("*")
@RequestMapping("/api/users") // Địa chỉ truy cập
public class UserController {

    @Autowired
    private UserRepository userRepository; // Gọi anh "Thủ kho" ra làm việc

    // API 1: Trả về toàn bộ danh sách User (Dùng lệnh GET)
    @GetMapping
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    // =======================================================
    // 2 API MỚI VỪA ĐƯỢC THÊM VÀO ĐÂY NÈ (THAY THẾ CHO API 2 CŨ)
    // =======================================================

    // API: ĐĂNG KÝ TÀI KHOẢN MỚI (MÃ HÓA)
    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody User user) {
        if (userRepository.findByUsername(user.getUsername()).isPresent()) {
            return ResponseEntity.badRequest().body("Tên đăng nhập đã tồn tại! Vui lòng chọn tên khác.");
        }

        // Băm mật khẩu (Hashing) trước khi lưu
        String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
        user.setPassword(hashedPassword);

        User savedUser = userRepository.save(user);
        return ResponseEntity.ok(savedUser);
    }

    // API: ĐĂNG NHẬP (KIỂM TRA MÃ HÓA)
    @PostMapping("/login")
    public ResponseEntity<?> loginUser(@RequestBody Map<String, String> credentials) {
        String username = credentials.get("username");
        String password = credentials.get("password");

        User user = userRepository.findByUsername(username).orElse(null);

        if (user == null) {
            return ResponseEntity.badRequest().body("Tài khoản không tồn tại!");
        }

        // So sánh mật khẩu nhập vào với mật khẩu đã băm trong DB
        if (!BCrypt.checkpw(password, user.getPassword())) {
            return ResponseEntity.badRequest().body("Sai mật khẩu!");
        }

        return ResponseEntity.ok(user);
    }

    // =======================================================
    // CÁC API CŨ BÊN DƯỚI GIỮ NGUYÊN HOÀN TOÀN
    // =======================================================

    @PutMapping("/update-progress")
    public ResponseEntity<?> updateProgress(@RequestParam String username) {
        // 1. Tìm đúng bạn Vũ (hoặc user đang học) trong Database
        User user = userRepository.findByUsername(username).orElse(null);

        if (user == null) {
            return ResponseEntity.badRequest().body("Không tìm thấy người dùng này!");
        }

        // 2. Cộng điểm thưởng (Mỗi bài học xong tặng 20 XP)
        user.setTotalXp(user.getTotalXp() + 20);

        // 3. Tính toán ngọn lửa Streak
        LocalDate today = LocalDate.now();
        LocalDate lastDate = user.getLastStudyDate();

        if (lastDate == null) {
            user.setStreak(1);
        } else {
            long daysBetween = ChronoUnit.DAYS.between(lastDate, today);
            if (daysBetween == 1) {
                user.setStreak(user.getStreak() + 1);
            } else if (daysBetween > 1) {
                user.setStreak(1);
            }
        }

        user.setLastStudyDate(today);
        userRepository.save(user);

        return ResponseEntity.ok(Map.of(
                "totalXp", user.getTotalXp(),
                "streak", user.getStreak(),
                "message", "Cập nhật tiến độ thành công!"
        ));
    }

    // API 3: Lấy thông tin cá nhân (XP, Streak) để hiển thị lên Home
    @GetMapping("/profile")
    public ResponseEntity<?> getUserProfile(@RequestParam String username) {
        User user = userRepository.findByUsername(username).orElse(null);

        if (user == null) {
            return ResponseEntity.badRequest().body("Không tìm thấy người dùng!");
        }

        return ResponseEntity.ok(Map.of(
                "totalXp", user.getTotalXp(),
                "streak", user.getStreak()
        ));
    }

    // API 4: Lấy Bảng xếp hạng Top 10
    @GetMapping("/leaderboard")
    public ResponseEntity<List<User>> getLeaderboard() {
        List<User> topUsers = userRepository.findTop10ByOrderByTotalXpDesc();
        return ResponseEntity.ok(topUsers);
    }
}