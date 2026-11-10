package com.vu.ai_learning_backend.modules.identity.presentation;

import com.vu.ai_learning_backend.modules.gamification.application.usecase.GetLeaderboardUseCase;
import com.vu.ai_learning_backend.modules.gamification.application.usecase.RecordLessonProgressRewardUseCase;
import com.vu.ai_learning_backend.modules.gamification.application.usecase.WaterPlantsUseCase;
import com.vu.ai_learning_backend.modules.identity.application.usecase.*;
import com.vu.ai_learning_backend.modules.identity.domain.model.User;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@CrossOrigin("*")
@RequestMapping("/api/users")
public class UserController {

    private final GetAllUsersUseCase getAllUsersUseCase;
    private final RegisterUserUseCase registerUserUseCase;
    private final AuthenticateUserUseCase authenticateUserUseCase;
    private final GetUserProfileUseCase getUserProfileUseCase;
    private final UpdateUserMajorUseCase updateUserMajorUseCase;
    private final WaterPlantsUseCase waterPlantsUseCase;
    private final RecordLessonProgressRewardUseCase recordLessonProgressRewardUseCase;
    private final GetLeaderboardUseCase getLeaderboardUseCase;

    public UserController(GetAllUsersUseCase getAllUsersUseCase,
                          RegisterUserUseCase registerUserUseCase,
                          AuthenticateUserUseCase authenticateUserUseCase,
                          GetUserProfileUseCase getUserProfileUseCase,
                          UpdateUserMajorUseCase updateUserMajorUseCase,
                          WaterPlantsUseCase waterPlantsUseCase,
                          RecordLessonProgressRewardUseCase recordLessonProgressRewardUseCase,
                          GetLeaderboardUseCase getLeaderboardUseCase) {
        this.getAllUsersUseCase = getAllUsersUseCase;
        this.registerUserUseCase = registerUserUseCase;
        this.authenticateUserUseCase = authenticateUserUseCase;
        this.getUserProfileUseCase = getUserProfileUseCase;
        this.updateUserMajorUseCase = updateUserMajorUseCase;
        this.waterPlantsUseCase = waterPlantsUseCase;
        this.recordLessonProgressRewardUseCase = recordLessonProgressRewardUseCase;
        this.getLeaderboardUseCase = getLeaderboardUseCase;
    }

    @GetMapping
    public List<User> getAllUsers() {
        return getAllUsersUseCase.execute();
    }

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody User user) {
        try {
            User savedUser = registerUserUseCase.execute(user);
            return ResponseEntity.ok(savedUser);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> loginUser(@RequestBody Map<String, String> credentials) {
        try {
            String username = credentials.get("username");
            String password = credentials.get("password");
            User user = authenticateUserUseCase.execute(username, password);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/update-plants")
    public ResponseEntity<?> updateWateredPlants(@RequestParam String username, @RequestParam int plants) {
        try {
            Map<String, Object> result = waterPlantsUseCase.execute(username, plants);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/update-major")
    public ResponseEntity<?> updateMajor(@RequestParam String username, @RequestParam String major) {
        try {
            User user = updateUserMajorUseCase.execute(username, major);
            return ResponseEntity.ok(Map.of(
                    "message", "Cập nhật chuyên ngành " + major + " thành công!",
                    "major", user.getMajor()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/update-progress")
    public ResponseEntity<?> updateProgress(@RequestParam String username) {
        try {
            Map<String, Object> result = recordLessonProgressRewardUseCase.execute(username);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getUserProfile(@RequestParam String username) {
        try {
            User user = getUserProfileUseCase.execute(username);
            return ResponseEntity.ok(Map.of(
                    "totalXp", user.getSafeTotalXp(),
                    "streak", user.getSafeStreak(),
                    "wateredPlants", user.getSafeWateredPlants()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/leaderboard")
    public ResponseEntity<List<User>> getLeaderboard() {
        List<User> topUsers = getLeaderboardUseCase.execute();
        return ResponseEntity.ok(topUsers);
    }
}

