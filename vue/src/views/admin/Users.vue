<template>
  <div class="users-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">用户管理</h1>
      <div class="header-actions">
        <el-button type="primary" @click="handleCreate">
          <el-icon><Plus /></el-icon>
          新增用户
        </el-button>
        <el-button @click="exportData">
          <el-icon><Download /></el-icon>
          导出数据
        </el-button>
      </div>
    </div>

    <!-- 搜索筛选 -->
    <el-card class="search-card">
      <el-form :model="searchForm" inline>
        <el-form-item label="用户名">
          <el-input
            v-model="searchForm.username"
            placeholder="请输入用户名"
            clearable
            style="width: 200px"
          />
        </el-form-item>
        <el-form-item label="用户角色">
          <el-select
            v-model="searchForm.role"
            placeholder="请选择角色"
            clearable
            style="width: 120px"
          >
            <el-option label="学生" value="STUDENT" />
            <el-option label="窗口管理员" value="WINDOW_MANAGER" />
            <el-option label="管理员" value="ADMIN" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select
            v-model="searchForm.status"
            placeholder="请选择状态"
            clearable
            style="width: 120px"
          >
            <el-option label="正常" value="active" />
            <el-option label="禁用" value="inactive" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 用户列表 -->
    <el-card>
      <template #header>
        <span>用户列表</span>
      </template>

      <el-table v-loading="loading" :data="users" style="width: 100%">
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column prop="studentId" label="学号" min-width="120" />
        <el-table-column label="头像" width="80">
          <template #default="scope">
            <el-avatar
              :size="40"
              :src="getImageUrl(scope.row.avatar)"
              :alt="scope.row.username"
            >
              {{ scope.row.username.charAt(0).toUpperCase() }}
            </el-avatar>
          </template>
        </el-table-column>
        <el-table-column prop="username" label="用户名" min-width="120" />
        <el-table-column prop="email" label="邮箱" min-width="150" />
        <el-table-column prop="phone" label="手机号" width="120" />
        <el-table-column prop="role" label="角色" width="100">
          <template #default="scope">
            <el-tag :type="getRoleType(scope.row.role)">
              {{ getRoleText(scope.row.role) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="tastePreference" label="个人偏好" width="120">
          <template #default="scope">
            <el-tooltip
              v-if="scope.row.tastePreference"
              :content="scope.row.tastePreference.join('、')"
            >
              <span
                >{{ scope.row.tastePreference.slice(0, 2).join("、")
                }}{{ scope.row.tastePreference.length > 2 ? "..." : "" }}</span
              >
            </el-tooltip>
            <span v-else>未设置</span>
          </template>
        </el-table-column>
        <el-table-column prop="totalOrders" label="订单数" width="80" />
        <el-table-column prop="totalSpent" label="消费金额" width="100">
          <template #default="scope"> ¥{{ scope.row.totalSpent }} </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-switch
              v-model="scope.row.status"
              active-value="active"
              inactive-value="inactive"
              @change="handleStatusChange(scope.row)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="注册时间" width="180">
          <template #default="scope">
            {{ formatTime(scope.row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="260" fixed="right">
          <template #default="scope">
            <el-button type="primary" text @click="handleEdit(scope.row)"
              >编辑</el-button
            >
            <el-button
              type="warning"
              text
              @click="handleResetPassword(scope.row)"
              >重置密码</el-button
            >
            <el-button type="danger" text @click="handleDelete(scope.row)"
              >删除</el-button
            >
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @update:page-size="handleSizeChange"
          @update:current-page="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 用户编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      :before-close="handleClose"
    >
      <el-form
        ref="userFormRef"
        :model="userForm"
        :rules="userRules"
        label-width="100px"
      >
        <el-form-item label="学号" prop="studentId">
          <el-input v-model="userForm.studentId" placeholder="请输入学号" :disabled="!!userForm.id" />
        </el-form-item>
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="userForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="userForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="用户角色" prop="role">
          <el-select v-model="userForm.role" placeholder="请选择角色">
            <el-option label="学生" value="STUDENT" />
            <el-option label="窗口管理员" value="WINDOW_MANAGER" />
            <el-option label="管理员" value="ADMIN" />
          </el-select>
        </el-form-item>
        <div class="preference-section">
          <h3 class="section-title">个人偏好</h3>
          <el-form-item label="辣度" prop="spicinessLevel">
            <div class="slider-container">
              <el-slider
                v-model="userForm.spicinessLevel"
                :min="1"
                :max="5"
                :marks="{
                  1: '不辣',
                  2: '微辣',
                  3: '适中',
                  4: '很辣',
                  5: '爆辣',
                }"
              />
              <span class="slider-value">{{
                getSpicinessText(userForm.spicinessLevel)
              }}</span>
            </div>
          </el-form-item>

          <el-form-item label="甜度" prop="sweetnessLevel">
            <div class="slider-container">
              <el-slider
                v-model="userForm.sweetnessLevel"
                :min="1"
                :max="5"
                :marks="{
                  1: '不甜',
                  2: '微甜',
                  3: '适中',
                  4: '很甜',
                  5: '超甜',
                }"
              />
              <span class="slider-value">{{
                getSweetnessText(userForm.sweetnessLevel)
              }}</span>
            </div>
          </el-form-item>

          <el-form-item label="其他味觉" prop="dietaryTags">
            <el-checkbox-group
              v-model="userForm.dietaryTags"
              class="category-tags"
            >
              <el-checkbox label="清淡" class="tag-checkbox" />
              <el-checkbox label="重口" class="tag-checkbox" />
              <el-checkbox label="鲜香" class="tag-checkbox" />
              <el-checkbox label="适中" class="tag-checkbox" />
            </el-checkbox-group>
          </el-form-item>

          <el-form-item label="饮食标签">
            <el-skeleton :loading="loadingTags" animated>
              <div v-if="!loadingTags" class="tag-categories">
                <div
                  v-for="(tags, category) in groupedTags"
                  :key="category"
                  class="tag-category"
                >
                  <h4 class="category-title">{{ category }}</h4>
                  <el-checkbox-group
                    v-model="userForm.dietaryTags"
                    class="category-tags"
                  >
                    <el-checkbox
                      v-for="tag in tags"
                      :key="tag"
                      :label="tag"
                      class="tag-checkbox"
                    />
                  </el-checkbox-group>
                </div>

                <div
                  v-if="Object.keys(groupedTags).length === 0"
                  class="no-tags"
                >
                  <p>暂无可用的饮食标签</p>
                </div>
              </div>
            </el-skeleton>
          </el-form-item>

          <el-form-item label="忌口信息" prop="dietaryRestrictions">
            <el-input
              v-model="userForm.dietaryRestrictions"
              type="textarea"
              :rows="3"
              placeholder="请输入用户的忌口信息，如：不吃香菜、海鲜过敏等"
            />
          </el-form-item>
        </div>
        <el-form-item label="头像" prop="avatar">
          <el-upload
            class="avatar-uploader"
            action="#"
            :show-file-list="false"
            :before-upload="beforeAvatarUpload"
            :http-request="handleAvatarUpload"
          >
            <img v-if="userForm.avatar" :src="getImageUrl(userForm.avatar)" class="avatar" />
            <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
          </el-upload>
        </el-form-item>
        <el-form-item v-if="!userForm.id" label="密码" prop="password">
          <el-input
            v-model="userForm.password"
            type="password"
            placeholder="请输入密码"
            show-password
          />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="userForm.status">
            <el-radio value="active">正常</el-radio>
            <el-radio value="inactive">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="handleClose">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { Plus, Download } from "@element-plus/icons-vue";
import { userApi } from "@/api/user";
import api, { resolveStaticUrl } from "@/api/index";

const loading = ref(false);
const dialogVisible = ref(false);
const submitting = ref(false);
const userFormRef = ref();

const searchForm = reactive({
  username: "",
  role: "",
  status: "",
});

const pagination = reactive({
  current: 1,
  size: 10,
  total: 0,
});

const userForm = reactive({
  id: "",
  studentId: "",
  username: "",
  email: "",
  phone: "",
  role: "STUDENT",
  tastePreference: [],
  spicinessLevel: 3,
  sweetnessLevel: 3,
  dietaryRestrictions: "",
  dietaryTags: [],
  avatar: "",
  password: "",
  status: "active",
});

const users = ref([]);
const loadingTags = ref(false);
const allDietaryTags = ref([]);

const tagCategories = {
  菜系偏好: [
    "川菜",
    "粤菜",
    "湘菜",
    "鲁菜",
    "苏菜",
    "浙菜",
    "闽菜",
    "徽菜",
    "东北菜",
    "西北菜",
    "家常菜",
  ],
  饮食类型: [
    "素食",
    "健身餐",
    "健康",
    "低脂",
    "高蛋白",
    "低碳水",
    "低糖",
    "清真",
    "无麸质",
  ],
};

const getSpicinessText = (level) => {
  const texts = {
    1: "不辣",
    2: "微辣",
    3: "适中",
    4: "很辣",
    5: "爆辣",
  };
  return texts[level] || "适中";
};

const getSweetnessText = (level) => {
  const texts = {
    1: "不甜",
    2: "微甜",
    3: "适中",
    4: "很甜",
    5: "超甜",
  };
  return texts[level] || "适中";
};

const groupedTags = computed(() => {
  const groups = {};
  const excludedTags = [
    "海鲜过敏",
    "不吃香菜",
    "不吃葱",
    "不吃蒜",
    "不吃羊肉",
    "爱吃肉",
    "清淡",
    "重口",
    "鲜香",
    "适中",
  ];

  Object.entries(tagCategories).forEach(([category, tags]) => {
    groups[category] = tags.filter((tag) => !excludedTags.includes(tag));
  });

  Object.keys(groups).forEach((category) => {
    if (groups[category].length === 0) {
      delete groups[category];
    }
  });

  return groups;
});

const userRules = {
  studentId: [
    { required: true, message: "请输入学号", trigger: "blur" },
  ],
  username: [{ required: true, message: "请输入用户名", trigger: "blur" }],
  email: [
    { required: true, message: "请输入邮箱", trigger: "blur" },
    { type: "email", message: "请输入正确的邮箱地址", trigger: "blur" },
  ],
  phone: [
    { required: true, message: "请输入手机号", trigger: "blur" },
    {
      pattern: /^1[3-9]\d{9}$/,
      message: "请输入正确的手机号",
      trigger: "blur",
    },
  ],
  role: [{ required: true, message: "请选择用户角色", trigger: "change" }],
  password: [
    { required: true, message: "请输入密码", trigger: "blur" },
    { min: 6, message: "密码长度不能少于 6 个字符", trigger: "blur" },
  ],
};

const normalizeRole = (role) => {
  if (!role) return "";
  const normalized = String(role).toUpperCase().trim();
  return normalized.startsWith("ROLE_") ? normalized.slice(5) : normalized;
};

// 获取角色类型
const getRoleType = (role) => {
  const types = {
    STUDENT: "primary",
    STAFF: "success",
    WINDOW_MANAGER: "success",
    ADMIN: "warning",
  };
  return types[normalizeRole(role)] || "info";
};

// 获取角色文本
const getRoleText = (role) => {
  const texts = {
    STUDENT: "学生",
    STAFF: "教职工",
    WINDOW_MANAGER: "窗口负责人",
    ADMIN: "管理员",
  };
  const normalized = normalizeRole(role);
  return texts[normalized] || role;
};

// 格式化时间
const formatTime = (timeStr) => {
  if (!timeStr) return "";
  return new Date(timeStr).toLocaleString("zh-CN");
};

const normalizeStatus = (status) => {
  if (status === true || status === 1 || status === "1") return "active";
  if (status === false || status === 0 || status === "0") return "inactive";
  if (!status) return "active";
  const normalized = String(status).toLowerCase();
  if (normalized === "active" || normalized === "inactive") return normalized;
  if (normalized === "enabled" || normalized === "normal") return "active";
  if (normalized === "disabled") return "inactive";
  return normalized;
};

// 获取图片URL
const getImageUrl = (url) => {
  return resolveStaticUrl(url);
};

// 获取状态类型搜索用户
const handleSearch = () => {
  pagination.current = 1;
  loadUsers();
};

// 重置搜索
const handleReset = () => {
  Object.keys(searchForm).forEach((key) => {
    searchForm[key] = "";
  });
  pagination.current = 1;
  loadUsers();
};

// 加载用户列表
const loadUsers = async () => {
  console.log("开始加载用户数据...");
  loading.value = true;

  // 定义数据处理函数
  const processUserData = (userData) => {
    console.log("处理用户数据:", userData);

    // 确保数据是数组格式
    const userArray = Array.isArray(userData) ? userData : [];

    // 转换数据格式
    users.value = userArray.map((user, index) => {
      return {
        id: user.id || index + 1,
        studentId: user.studentId || "-",
        username: user.username || user.studentId || `用户${index + 1}`,
        email: user.email || "-",
        phone: user.phone || "-",
        role: user.role || "STUDENT",
        status: normalizeStatus(user.status),
        avatar: user.avatar || "/default-avatar.png",
        tastePreference: user.tastePreference || user.dietaryTags || [],
        dietaryTags: user.dietaryTags || [],
        spicinessLevel: user.spicinessLevel ?? 3,
        sweetnessLevel: user.sweetnessLevel ?? 3,
        dietaryRestrictions: user.dietaryRestrictions ?? "",
        totalOrders: user.totalOrders || 0,
        totalSpent: user.totalSpent || 0,
        createdAt:
          user.createTime || user.createdAt || new Date().toISOString(),
      };
    });

    pagination.total = users.value.length;

    if (users.value.length === 0) {
      ElMessage.info("暂无用户数据");
    }

    return users.value;
  };

  try {
    console.log("加载用户数据...");

    // 构建查询参数
    const params = {};
    if (searchForm.username && searchForm.username.trim()) {
      params.username = searchForm.username.trim();
    }
    if (searchForm.role) {
      params.role = searchForm.role;
    }

    const response = await userApi.getUsers(params);
    if (response && response.data && Array.isArray(response.data)) {
      const list = processUserData(response.data);
      if (searchForm.status) {
        const statusValue = normalizeStatus(searchForm.status);
        users.value = list.filter(
          (u) => normalizeStatus(u.status) === statusValue,
        );
        pagination.total = users.value.length;
      }
      console.log("数据加载成功");
    } else {
      users.value = [];
      pagination.total = 0;
      ElMessage.info("暂无用户数据");
    }
  } catch (error) {
    console.error("用户数据加载失败:", error);
    ElMessage.error("加载用户数据失败");
    users.value = [];
    pagination.total = 0;
  } finally {
    loading.value = false;
    console.log("用户数据加载完成");
  }
};

const loadAllDietaryTags = async () => {
  try {
    loadingTags.value = true;
    const response = await userApi.getDietaryTags();
    if (response?.status === 200 && Array.isArray(response.data)) {
      allDietaryTags.value = response.data;
    }
  } catch (error) {
    allDietaryTags.value = [];
  } finally {
    loadingTags.value = false;
  }
};

const normalizeDietaryTagsForEdit = (tags, restrictions) => {
  const list = Array.isArray(tags) ? tags : [];
  const filtered = list.filter((t) => {
    if (!t) return false;
    if (typeof t !== "string") return false;
    if (t.startsWith("辣度:") || t.startsWith("甜度:")) return false;
    if (restrictions && t === restrictions) return false;
    return true;
  });
  return Array.from(new Set(filtered));
};

// 新增用户
const handleCreate = () => {
  dialogVisible.value = true;
  Object.keys(userForm).forEach((key) => {
    userForm[key] = "";
  });
  userForm.role = "STUDENT";
  userForm.status = "active";
  userForm.tastePreference = [];
  userForm.spicinessLevel = 3;
  userForm.sweetnessLevel = 3;
  userForm.dietaryRestrictions = "";
  userForm.dietaryTags = [];
};

// 编辑用户
const handleEdit = (row) => {
  dialogVisible.value = true;
  Object.assign(userForm, row);
  userForm.spicinessLevel = row.spicinessLevel ?? 3;
  userForm.sweetnessLevel = row.sweetnessLevel ?? 3;
  userForm.dietaryRestrictions = row.dietaryRestrictions ?? "";
  userForm.dietaryTags = normalizeDietaryTagsForEdit(
    row.dietaryTags || row.tastePreference || [],
    userForm.dietaryRestrictions,
  );
};

// 重置密码
const handleResetPassword = async (row) => {
  try {
    await ElMessageBox.confirm("确定要重置这个用户的密码吗？", "提示", {
      type: "warning",
    });

    await userApi.resetPassword(row.id, "123456");
    ElMessage.success("密码已重置为默认密码");
  } catch (error) {
    if (error !== "cancel") {
      console.error("重置密码失败:", error);
      ElMessage.error("重置密码失败");
    }
    // 用户取消操作不处理
  }
};

// 删除用户
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm("确定要删除这个用户吗？", "提示", {
      type: "warning",
    });

    // 调用API删除用户
    await userApi.deleteUser(row.id);
    ElMessage.success("删除成功");
    loadUsers();
  } catch (error) {
    if (error !== "cancel") {
      console.error("删除用户失败:", error);
      ElMessage.error("删除失败");
    }
    // 用户取消删除不处理
  }
};

// 状态切换
const handleStatusChange = async (row) => {
  try {
    await userApi.updateUserStatus(row.id, row.status);
    ElMessage.success(`用户已${row.status === "active" ? "启用" : "禁用"}`);
  } catch (error) {
    row.status = row.status === "active" ? "inactive" : "active";
    ElMessage.error("操作失败");
  }
};

// 关闭对话框
const handleClose = () => {
  dialogVisible.value = false;
  userFormRef.value?.resetFields();
};

// 提交表单
const handleSubmit = async () => {
  if (!userFormRef.value) return;

  try {
    await userFormRef.value.validate();
    submitting.value = true;

    const preferencesData = {
      spicinessLevel: parseInt(userForm.spicinessLevel),
      sweetnessLevel: parseInt(userForm.sweetnessLevel),
      dietaryRestrictions: userForm.dietaryRestrictions,
      dietaryTags: Array.isArray(userForm.dietaryTags)
        ? userForm.dietaryTags
        : [],
    };

    const userData = {
      ...userForm,
      password: userForm.password || undefined,
    };

    delete userData.tastePreference;
    delete userData.dietaryTags;
    delete userData.spicinessLevel;
    delete userData.sweetnessLevel;
    delete userData.dietaryRestrictions;
    delete userData.totalOrders;
    delete userData.totalSpent;
    delete userData.createdAt;

    if (userForm.id) {
      await userApi.updateUser(userForm.id, userData);
      await userApi.updatePreferences(userForm.id, preferencesData);
      ElMessage.success("更新成功");
    } else {
      const res = await userApi.createUser(userData);
      const createdId = res?.data?.user?.id || res?.data?.id;
      if (createdId) {
        await userApi.updatePreferences(createdId, preferencesData);
      }
      ElMessage.success("创建成功");
    }

    dialogVisible.value = false;
    loadUsers();
  } catch (error) {
    console.error("提交失败:", error);
    ElMessage.error(error.message || "操作失败");
  } finally {
    submitting.value = false;
  }
};

// 图片上传前检查
const beforeAvatarUpload = (file) => {
  const isJPG = file.type === "image/jpeg";
  const isPNG = file.type === "image/png";
  const isLt2M = file.size / 1024 / 1024 < 2;

  if (!isJPG && !isPNG) {
    ElMessage.error("图片只能是 JPG 或 PNG 格式!");
    return false;
  }
  if (!isLt2M) {
    ElMessage.error("图片大小不能超过 2MB!");
    return false;
  }
  return true;
};

// 处理图片上传
const handleAvatarUpload = async (options) => {
  const file = options.file;
  const formData = new FormData();
  formData.append("file", file);

  try {
    const res = await api.post("/api/upload", formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });
    
    if (res.data && res.data.url) {
      userForm.avatar = res.data.url;
      ElMessage.success("头像上传成功");
    }
  } catch (error) {
    console.error("头像上传失败:", error);
    ElMessage.error("头像上传失败");
  }
};

// 导出数据
const exportData = async () => {
  try {
    ElMessage.info("正在生成导出文件...");
    
    const params = {};
    if (searchForm.username && searchForm.username.trim()) {
      params.username = searchForm.username.trim();
    }
    if (searchForm.role) {
      params.role = searchForm.role;
    }
    if (searchForm.status) {
      params.status = searchForm.status;
    }

    const response = await api.get('/api/users/export', {
      params,
      responseType: 'blob'
    });

    const url = window.URL.createObjectURL(new Blob([response.data]));
    const link = document.createElement('a');
    link.href = url;
    
    const contentDisposition = response.headers['content-disposition'];
    let fileName = `用户列表_${new Date().toISOString().slice(0,10)}.xlsx`;
    if (contentDisposition) {
      const fileNameMatch = contentDisposition.match(/filename\*=utf-8''(.+)/);
      if (fileNameMatch && fileNameMatch.length === 2) {
        fileName = decodeURIComponent(fileNameMatch[1]);
      }
    }
    
    link.setAttribute('download', fileName);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
    
    ElMessage.success("导出成功");
  } catch (error) {
    console.error("导出失败:", error);
    ElMessage.error("导出失败");
  }
};

// 分页大小改变
const handleSizeChange = (size) => {
  pagination.size = size;
  pagination.current = 1;
  loadUsers();
};

// 当前页改变
const handleCurrentChange = (current) => {
  pagination.current = current;
  loadUsers();
};

const dialogTitle = computed(() => {
  return userForm.id ? "编辑用户" : "新增用户";
});

onMounted(async () => {
  console.log("页面加载，开始加载用户数据...");
  // 直接调用简化版加载函数
  loadUsers();
  loadAllDietaryTags();
});
</script>

<style scoped>
.users-container {
  width: 100%;
  margin: 0;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.preference-section {
  margin: 10px 0 0;
  padding-top: 4px;
}

.section-title {
  margin: 0 0 12px;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.slider-container {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
}

.slider-container :deep(.el-slider) {
  flex: 1;
  min-width: 200px;
}

.slider-value {
  min-width: 48px;
  text-align: right;
  color: #606266;
}

.tag-categories {
  width: 100%;
}

.tag-category {
  margin-bottom: 12px;
}

.category-title {
  margin: 0 0 8px;
  font-size: 13px;
  color: #606266;
}

.category-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10px 12px;
}

.tag-checkbox {
  margin-right: 0;
}

.no-tags {
  color: #909399;
  font-size: 13px;
}

.page-title {
  font-size: 24px;
  color: #333;
  margin: 0;
}

.search-card {
  margin-bottom: 20px;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.avatar-uploader {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  width: 100px;
  height: 100px;
}

.avatar-uploader:hover {
  border-color: #409eff;
}

.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 100px;
  height: 100px;
  line-height: 100px;
  text-align: center;
}

.avatar {
  width: 100px;
  height: 100px;
  display: block;
}
</style>
