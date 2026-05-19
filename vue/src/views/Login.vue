<template>
  <div class="login-container">
    <div class="login-form">
      <div class="login-header">
        <h2>高校食堂菜品推荐系统</h2>
        <p>请登录您的账户</p>
      </div>

      <el-form
        ref="loginFormRef"
        :model="loginForm"
        :rules="loginRules"
        class="form"
      >
        <el-form-item prop="studentId">
          <el-input
            v-model="loginForm.studentId"
            placeholder="请输入学号"
            size="large"
            prefix-icon="User"
          />
        </el-form-item>

        <el-form-item prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="请输入密码"
            size="large"
            prefix-icon="Lock"
            show-password
          />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            size="large"
            class="login-btn"
            :loading="loading"
            @click="handleLogin"
          >
            登录
          </el-button>
        </el-form-item>
      </el-form>

      <div class="login-footer">
        <span>还没有账户？</span>
        <el-link type="primary" @click="$router.push('/register')"
          >立即注册</el-link
        >
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { useUserStore } from "@/stores/user";
import { userApi } from "@/api/user";

const router = useRouter();
const userStore = useUserStore();

const loginFormRef = ref();
const loading = ref(false);

const loginForm = reactive({
  studentId: "",
  password: "",
});

const loginRules = {
  studentId: [{ required: true, message: "请输入学号", trigger: "blur" }],
  password: [
    { required: true, message: "请输入密码", trigger: "blur" },
    { min: 6, message: "密码长度不能少于6位", trigger: "blur" },
  ],
};

const handleLogin = async () => {
  if (!loginFormRef.value) return;

  try {
    const valid = await loginFormRef.value.validate();
    if (!valid) return;

    loading.value = true;

    // 打印登录请求参数，用于调试
    console.log("登录请求参数:", { studentId: loginForm.studentId });

    const response = await userApi.login({
      studentId: loginForm.studentId,
      password: loginForm.password,
    });

    // 打印响应数据，用于调试
    console.log("登录响应:", response);

    // 正确处理后端返回的嵌套数据格式
    const loginData = response.data?.data || response.data;
    if (!loginData) {
      throw new Error("登录响应数据格式错误");
    }

    userStore.login(loginData);
    ElMessage.success("登录成功");

    // 根据用户角色跳转到不同页面
    if (userStore.canAccessAdmin) {
      router.push("/admin");
    } else {
      router.push("/home");
    }
  } catch (error) {
    console.error("登录错误:", error);
    // 如果有具体错误信息，显示具体信息，否则显示默认错误
    if (error.response?.data?.message) {
      ElMessage.error(error.response.data.message);
    } else {
      ElMessage.error("登录失败，请检查学号和密码");
    }
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-form {
  background: white;
  padding: 40px;
  border-radius: 10px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  width: 400px;
}

.login-header {
  text-align: center;
  margin-bottom: 30px;
}

.login-header h2 {
  color: #333;
  margin-bottom: 10px;
}

.login-header p {
  color: #666;
  font-size: 14px;
}

.form {
  margin-bottom: 20px;
}

.login-btn {
  width: 100%;
  margin-top: 10px;
}

.login-footer {
  text-align: center;
  color: #666;
  font-size: 14px;
}

.login-footer .el-link {
  margin-left: 5px;
}
</style>
