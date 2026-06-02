package com.school.canteen.service.miniapp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MiniAppSession {
    private String openid;
    private String sessionKey;
}
