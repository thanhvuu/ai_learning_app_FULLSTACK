package com.vu.ai_learning_backend.repository;

import com.vu.ai_learning_backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List; // Nhớ import List
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // Chỉ cần kế thừa JpaRepository, Spring Boot sẽ tự động viết sẵn
    // các lệnh SQL như FindAll (Lấy hết), Save (Lưu), Delete (Xóa) cho bạn!

    Optional<User> findByUsername(String username);//tim user theo ten dang nhap
    //Tìm Top 10 người có XP cao nhất, sắp xếp giảm dần (Desc)
    List<User> findTop10ByOrderByTotalXpDesc();
}