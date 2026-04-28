<template>
  <div class="register-container">
    <div class="register-form">
      <div class="register-header">
        <h2>学生注册</h2>
        <p>请填写您的个人信息</p>
      </div>

      <el-form
        ref="registerFormRef"
        :model="registerForm"
        :rules="registerRules"
        class="form"
      >
        <el-form-item prop="studentId">
          <el-input
            v-model="registerForm.studentId"
            placeholder="请输入学号"
            size="large"
            prefix-icon="User"
          />
        </el-form-item>

        <el-form-item prop="username">
          <el-input
            v-model="registerForm.username"
            placeholder="请输入姓名"
            size="large"
            prefix-icon="User"
          />
        </el-form-item>

        <el-form-item prop="password">
          <el-input
            v-model="registerForm.password"
            type="password"
            placeholder="请输入密码"
            size="large"
            prefix-icon="Lock"
            show-password
          />
        </el-form-item>

        <el-form-item prop="confirmPassword">
          <el-input
            v-model="registerForm.confirmPassword"
            type="password"
            placeholder="请确认密码"
            size="large"
            prefix-icon="Lock"
            show-password
          />
        </el-form-item>

        <el-form-item prop="email">
          <el-input
            v-model="registerForm.email"
            placeholder="请输入邮箱"
            size="large"
            prefix-icon="Message"
          />
        </el-form-item>

        <el-form-item prop="phone">
          <el-input
            v-model="registerForm.phone"
            placeholder="请输入手机号"
            size="large"
            prefix-icon="Phone"
          />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            size="large"
            class="register-btn"
            :loading="loading"
            @click="handleRegister"
          >
            注册
          </el-button>
        </el-form-item>
      </el-form>

      <div class="register-footer">
        <span>已有账户？</span>
        <el-link type="primary" @click="$router.push('/login')"
          >立即登录</el-link
        >
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { userApi } from "@/api/user";

const router = useRouter();

const registerFormRef = ref();
const loading = ref(false);

const registerForm = reactive({
  studentId: "",
  username: "",
  password: "",
  confirmPassword: "",
  email: "",
  phone: "",
});

const validateConfirmPassword = (rule, value, callback) => {
  if (value !== registerForm.password) {
    callback(new Error("两次输入的密码不一致"));
  } else {
    callback();
  }
};

const registerRules = {
  studentId: [
    { required: true, message: "请输入学号", trigger: "blur" },
    { pattern: /^\d{8,12}$/, message: "学号格式不正确", trigger: "blur" },
  ],
  username: [
    { required: true, message: "请输入姓名", trigger: "blur" },
    { min: 2, max: 20, message: "姓名长度在2-20个字符", trigger: "blur" },
  ],
  password: [
    { required: true, message: "请输入密码", trigger: "blur" },
    { min: 6, message: "密码长度不能少于6位", trigger: "blur" },
  ],
  confirmPassword: [
    { required: true, message: "请确认密码", trigger: "blur" },
    { validator: validateConfirmPassword, trigger: "blur" },
  ],
  email: [
    { required: true, message: "请输入邮箱", trigger: "blur" },
    { type: "email", message: "邮箱格式不正确", trigger: "blur" },
  ],
  phone: [
    { required: true, message: "请输入手机号", trigger: "blur" },
    { pattern: /^1[3-9]\d{9}$/, message: "手机号格式不正确", trigger: "blur" },
  ],
};

const handleRegister = async () => {
  if (!registerFormRef.value) return;

  try {
    const valid = await registerFormRef.value.validate();
    if (!valid) return;

    loading.value = true;

    await userApi.register({
      studentId: registerForm.studentId,
      username: registerForm.username,
      password: registerForm.password,
      email: registerForm.email,
      phone: registerForm.phone,
    });

    ElMessage.success("注册成功，请登录");
    router.push("/login");
  } catch (error) {
    ElMessage.error("注册失败，请稍后重试");
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.register-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.register-form {
  background: white;
  padding: 40px;
  border-radius: 10px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  width: 450px;
  max-height: 90vh;
  overflow-y: auto;
}

.register-header {
  text-align: center;
  margin-bottom: 30px;
}

.register-header h2 {
  color: #333;
  margin-bottom: 10px;
}

.register-header p {
  color: #666;
  font-size: 14px;
}

.form {
  margin-bottom: 20px;
}

.register-btn {
  width: 100%;
  margin-top: 10px;
}

.register-footer {
  text-align: center;
  color: #666;
  font-size: 14px;
}

.register-footer .el-link {
  margin-left: 5px;
}
</style>
