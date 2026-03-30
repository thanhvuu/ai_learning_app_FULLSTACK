package com.vu.ai_learning_backend.controller;

import com.vu.ai_learning_backend.entity.User;
import com.vu.ai_learning_backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController // Khai báo đây là đầu mối API
@RequestMapping("/api/users") // Địa chỉ truy cập
public class UserController {

    @Autowired
    private UserRepository userRepository; // Gọi anh "Thủ kho" ra làm việc

    // API 1: Trả về toàn bộ danh sách User (Dùng lệnh GET)
    @GetMapping
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    // API 2: Tạo một User mới (Dùng lệnh POST)
    @PostMapping
    public User createUser(@RequestBody User user) {
        return userRepository.save(user);
    }
}