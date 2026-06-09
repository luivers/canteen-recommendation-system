package com.school.canteen.smoke;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.school.canteen.CanteenOrderingApplication;
import com.school.canteen.entity.Dish;
import com.school.canteen.entity.User;
import com.school.canteen.entity.Window;
import com.school.canteen.repository.DishRepository;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.repository.WindowRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.cache.CacheManager;
import org.springframework.cache.concurrent.ConcurrentMapCache;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;
import org.springframework.context.annotation.Import;
import org.springframework.core.task.SyncTaskExecutor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.mock.web.MockMultipartFile;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(classes = CanteenOrderingApplication.class)
@AutoConfigureMockMvc
@ActiveProfiles("smoke-test")
@Import(BackendCoreSmokeTest.SmokeAsyncConfig.class)
class BackendCoreSmokeTest {

    private static final String STUDENT_ID = "ST020001";
    private static final String ADMIN_ID = "ST020ADMIN";
    private static final String PASSWORD = "pass123456";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private DishRepository dishRepository;

    @Autowired
    private WindowRepository windowRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @MockBean
    private CacheManager cacheManager;

    @BeforeEach
    void configureCacheManager() {
        when(cacheManager.getCache(anyString()))
            .thenAnswer(invocation -> new ConcurrentMapCache(invocation.getArgument(0, String.class)));
    }

    @Test
    void backendCorePathSupportsLoginOrderPaymentReviewAndPoints() throws Exception {
        SeedData seed = seedCoreData();

        String studentToken = login(STUDENT_ID, PASSWORD);
        String adminToken = login(ADMIN_ID, PASSWORD);

        mockMvc.perform(get("/api/users/me").header("Authorization", bearer(studentToken)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.studentId").value(STUDENT_ID));

        MvcResult orderResult = mockMvc.perform(post("/api/orders")
                .header("Authorization", bearer(studentToken))
                .contentType("application/json")
                .content(objectMapper.writeValueAsString(Map.of(
                    "items", List.of(Map.of("dishId", seed.dishId(), "quantity", 2)),
                    "pickupType", "IMMEDIATE",
                    "remarks", "ST-020 backend smoke"
                ))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("SUCCESS"))
            .andExpect(jsonPath("$.orderId").isNumber())
            .andExpect(jsonPath("$.totalAmount").value(25.00))
            .andReturn();

        JsonNode orderJson = readJson(orderResult);
        long orderId = orderJson.get("orderId").asLong();
        String orderNumber = orderJson.get("orderNumber").asText();
        assertTrue(orderNumber.startsWith("ORD"));

        mockMvc.perform(post("/api/payments/orders/{orderId}/create", orderId)
                .header("Authorization", bearer(studentToken))
                .contentType("application/json")
                .content(objectMapper.writeValueAsString(Map.of("paymentMethod", "WECHAT"))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.mode").value("mock"))
            .andExpect(jsonPath("$.provider").value("MOCK"))
            .andExpect(jsonPath("$.orderId").value(orderId))
            .andExpect(jsonPath("$.status").value("CREATED"));

        mockMvc.perform(post("/api/payments/orders/{orderId}/success", orderId)
                .header("Authorization", bearer(studentToken))
                .contentType("application/json")
                .content(objectMapper.writeValueAsString(Map.of(
                    "paymentMethod", "WECHAT",
                    "transactionId", "MOCK-" + orderNumber + "-ST020"
                ))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("PAID"))
            .andExpect(jsonPath("$.transactionId").value("MOCK-" + orderNumber + "-ST020"));

        mockMvc.perform(get("/api/payments/orders/{orderId}/status", orderId)
                .header("Authorization", bearer(studentToken)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.localStatus").value("PAID"))
            .andExpect(jsonPath("$.providerStatus").value("PAID"));

        mockMvc.perform(put("/api/orders/{orderId}/prepare", orderId)
                .header("Authorization", bearer(adminToken)))
            .andExpect(status().isOk());

        mockMvc.perform(put("/api/orders/{orderId}/ready", orderId)
                .header("Authorization", bearer(adminToken)))
            .andExpect(status().isOk());

        mockMvc.perform(put("/api/orders/{orderId}/confirm-pickup", orderId)
                .header("Authorization", bearer(studentToken)))
            .andExpect(status().isOk());

        MockMultipartFile reviewPart = new MockMultipartFile(
            "review",
            "",
            "application/json",
            objectMapper.writeValueAsBytes(Map.of(
                "orderId", orderId,
                "tasteRating", 5,
                "portionRating", 5,
                "priceRating", 5,
                "hygieneRating", 5,
                "comment", "味道很好，分量足，价格实惠，整体体验不错，值得推荐。",
                "quickTags", List.of("好吃", "推荐"),
                "items", List.of(Map.of("dishId", seed.dishId(), "rating", 5))
            ))
        );

        MvcResult reviewResult = mockMvc.perform(multipart("/api/reviews")
                .file(reviewPart)
                .header("Authorization", bearer(studentToken)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.code").value("REVIEW_CREATED"))
            .andExpect(jsonPath("$.data.id").isNumber())
            .andReturn();

        long reviewId = readJson(reviewResult).at("/data/id").asLong();
        assertTrue(reviewId > 0);

        int points = awaitPointsAtLeast(studentToken, 10);
        assertTrue(points >= 10, "review reward should add at least the basic review points");

        MvcResult historyResult = mockMvc.perform(get("/api/points/history/me")
                .header("Authorization", bearer(studentToken)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.code").value("POINT_HISTORY_FETCHED"))
            .andReturn();
        JsonNode historyJson = readJson(historyResult);
        assertTrue(historyJson.get("total").asInt() >= 1, "point history should include review reward logs");
        assertEquals("REVIEW_REWARD", historyJson.at("/data/0/source").asText());
    }

    private SeedData seedCoreData() {
        User student = userRepository.save(user(STUDENT_ID, "ST-020学生", User.UserRole.STUDENT));
        User admin = userRepository.save(user(ADMIN_ID, "ST-020管理员", User.UserRole.ADMIN));
        assertNotNull(student.getId());
        assertNotNull(admin.getId());

        Window window = new Window();
        window.setName("ST-020测试窗口");
        window.setLocation("一食堂一楼");
        window.setStatus(Window.WindowStatus.OPEN);
        window.setCanteenId(1L);
        window.setCanteenName("第一食堂");
        window = windowRepository.save(window);

        Dish dish = new Dish();
        dish.setName("ST-020测试套餐饭");
        dish.setDescription("后端冒烟测试菜品");
        dish.setPrice(new BigDecimal("12.50"));
        dish.setStatus(Dish.DishStatus.AVAILABLE);
        dish.setDishCategory(Dish.DishCategory.MAIN_DISH);
        dish.setStock(50);
        dish.setDailyLimit(100);
        dish.setCanteenId(1L);
        dish.setCanteenName("第一食堂");
        dish.setWindowId(window.getId());
        dish.setWindowName(window.getName());
        dish.setWindowLocation(window.getLocation());
        dish = dishRepository.save(dish);

        return new SeedData(dish.getId());
    }

    private User user(String studentId, String username, User.UserRole role) {
        User user = new User();
        user.setStudentId(studentId);
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(PASSWORD));
        user.setRole(role);
        user.setStatus("active");
        user.setPoints(0);
        return user;
    }

    private String login(String studentId, String password) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/users/login")
                .contentType("application/json")
                .content(objectMapper.writeValueAsString(Map.of(
                    "studentId", studentId,
                    "password", password
                ))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data.token").isString())
            .andReturn();

        String token = readJson(result).at("/data/token").asText();
        assertNotNull(token);
        return token;
    }

    private int awaitPointsAtLeast(String token, int expectedMinimum) throws Exception {
        long deadline = System.currentTimeMillis() + 5000;
        int latestPoints = 0;
        while (System.currentTimeMillis() < deadline) {
            MvcResult balanceResult = mockMvc.perform(get("/api/points/balance")
                    .header("Authorization", bearer(token)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("POINT_BALANCE_FETCHED"))
                .andReturn();
            latestPoints = readJson(balanceResult).at("/data/points").asInt();
            if (latestPoints >= expectedMinimum) {
                return latestPoints;
            }
            Thread.sleep(100);
        }
        return latestPoints;
    }

    private JsonNode readJson(MvcResult result) throws Exception {
        return objectMapper.readTree(result.getResponse().getContentAsString());
    }

    private String bearer(String token) {
        return "Bearer " + token;
    }

    private record SeedData(Long dishId) {
    }

    @TestConfiguration
    @Profile("smoke-test")
    static class SmokeAsyncConfig {
        @Bean(name = "taskExecutor")
        SyncTaskExecutor taskExecutor() {
            return new SyncTaskExecutor();
        }
    }
}
