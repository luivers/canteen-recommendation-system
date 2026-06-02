package com.school.canteen.service.miniapp.dto;

import com.school.canteen.entity.User;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class MiniAppLoginResponse {
    private String token;
    private MiniAppUserView user;
    private boolean isNewUser;

    public static MiniAppLoginResponse of(String token, User user, boolean isNewUser) {
        return new MiniAppLoginResponse(token, MiniAppUserView.of(user), isNewUser);
    }

    @Data
    @AllArgsConstructor
    public static class MiniAppUserView {
        private Long id;
        private String studentId;
        private String username;
        private String role;
        private String avatar;
        private Integer points;

        public static MiniAppUserView of(User user) {
            return new MiniAppUserView(
                    user.getId(),
                    user.getStudentId(),
                    user.getUsername(),
                    user.getRole() == null ? null : user.getRole().name(),
                    user.getAvatar(),
                    user.getPoints()
            );
        }
    }
}
