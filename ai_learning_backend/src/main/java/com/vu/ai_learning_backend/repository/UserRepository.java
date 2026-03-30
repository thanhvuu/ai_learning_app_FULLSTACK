package com.vu.ai_learning_backend.repository;

import com.vu.ai_learning_backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // Chỉ cần kế thừa JpaRepository, Spring Boot sẽ tự động viết sẵn
    // các lệnh SQL như FindAll (Lấy hết), Save (Lưu), Delete (Xóa) cho bạn!
}