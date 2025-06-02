// Hàm hiển thị modal với thông tin chi tiết của mỗi chỉ số
function showModal(metric, card) {
    const modal = document.getElementById('modal');
    const title = document.getElementById('modal-title');
    const status = document.getElementById('modal-status');
    const warning = document.getElementById('modal-warning');
    const healthy = document.getElementById('modal-healthy');
    const unhealthy = document.getElementById('modal-unhealthy');
    const suggestions = document.getElementById('modal-suggestions');

    const value = getValueFromCard(card);

    // Cập nhật nội dung modal dựa trên thông tin tính toán
    const data = getMetricData(metric, value);

    updateModalContent(data, title, status, warning, healthy, unhealthy, suggestions);

    // Hiển thị modal
    modal.style.display = 'block';
    document.body.style.overflow = 'hidden'; // Ngăn cuộn trang nền
}

// Hàm đóng modal
function closeModal() {
    const modal = document.getElementById('modal');
    modal.style.display = 'none';
    document.body.style.overflow = 'auto'; // Cho phép cuộn lại
}

// Đóng modal khi nhấp ngoài modal
window.onclick = function(event) {
    const modal = document.getElementById('modal');
    if (event.target === modal) {
        closeModal();
    }
}
// Đóng modal khi nhấn phím Escape
window.addEventListener('keydown', function(event) {
    const modal = document.getElementById('modal');
    if (event.key === 'Escape' && modal.style.display === 'block') {
        closeModal();
    }
});


// Lấy giá trị từ card (sử dụng regex để tìm giá trị số)
function getValueFromCard(card) {
    const valueText = card.querySelector('p:not(.card-alert-message)').textContent;
    const match = valueText.match(/[\d.]+/);
    return match ? parseFloat(match[0]) : NaN; // Trả về NaN nếu không tìm thấy số để xử lý tốt hơn
}

// Cập nhật nội dung cho modal
function updateModalContent(data, title, status, warning, healthy, unhealthy, suggestions) {
    title.textContent = data.title;
    status.textContent = `${data.statusText}`; 
    
    const modalWarningElement = document.getElementById('modal-warning');
    if (data.warning && data.warning.trim() !== '') {
        modalWarningElement.innerHTML = data.warning; 
        modalWarningElement.style.display = 'block';
    } else {
        modalWarningElement.style.display = 'none';
    }
    
    healthy.textContent = data.healthy;
    unhealthy.textContent = data.unhealthy;
    suggestions.textContent = data.suggestions;
}


// Hàm lấy dữ liệu cho từng chỉ số
function getMetricData(metric, value) {
    const metricsData = {
        'temperature': getTemperatureData(value),
        'humidity': getHumidityData(value),
        'weight': getWeightData(value),
        'heartRate': getHeartRateData(value),
        'spo2': getSpO2Data(value)
    };

    return metricsData[metric] || {};
}

// Cấu trúc dữ liệu cho mỗi chỉ số và các cảnh báo (giữ nguyên logic, chỉ thay đổi image paths trong generateHealthTip)
function getTemperatureData(value) {
    let data = {
        title: 'Nhiệt Độ Môi Trường',
        value: value,
        statusText: `Hiện tại: ${isNaN(value) ? '--' : value.toFixed(1)}°C. Nhiệt độ môi trường ở mức thoải mái.`,
        warning: '',
        healthy: '20°C - 28°C: Nhiệt độ môi trường thoải mái, lý tưởng cho sinh hoạt.',
        unhealthy: '< 20°C: Môi trường lạnh, có thể gây cảm lạnh, khó chịu. \n> 28°C: Môi trường nóng, dễ gây mất nước, say nắng.',
        suggestions: 'Điều chỉnh nhiệt độ phòng bằng điều hòa, quạt hoặc máy sưởi. Mặc quần áo phù hợp với nhiệt độ.',
        alertLevel: 'normal',
        alertMessage: ''
    };

    if (isNaN(value)) {
        data.statusText = 'Chưa có dữ liệu nhiệt độ.';
        return data;
    }

    if (value < 20) {
        data = setAlertData(data, 'Thấp', `Hiện tại: ${value.toFixed(1)}°C. Nhiệt độ môi trường quá lạnh.`, 'CẢNH BÁO: Nhiệt độ thấp! Có thể ảnh hưởng đến sức khỏe, đặc biệt là người già và trẻ nhỏ.', 'Giữ ấm cơ thể bằng quần áo nhiều lớp, sử dụng máy sưởi, uống đồ uống ấm. Đảm bảo nhà cửa kín gió.');
        data.alertLevel = 'danger';
        data.alertMessage = 'Quá lạnh!';
    } else if (value > 28) {
        data = setAlertData(data, 'Cao', `Hiện tại: ${value.toFixed(1)}°C. Nhiệt độ môi trường quá nóng.`, 'CẢNH BÁO: Nhiệt độ cao! Nguy cơ mất nước, say nắng, kiệt sức do nóng.', 'Sử dụng quạt hoặc điều hòa, uống đủ nước (nước lọc, nước trái cây), hạn chế ra ngoài trời vào giờ cao điểm nắng nóng, mặc quần áo thoáng mát.');
        data.alertLevel = 'danger';
        data.alertMessage = 'Quá nóng!';
    }
    return data;
}

function getHumidityData(value) {
    let data = {
        title: 'Độ Ẩm Môi Trường',
        value: value,
        statusText: `Hiện tại: ${isNaN(value) ? '--' : value.toFixed(1)}%. Độ ẩm môi trường ở mức thoải mái.`,
        warning: '',
        healthy: '40% - 60%: Mức độ ẩm lý tưởng, tốt cho sức khỏe và đồ đạc.',
        unhealthy: '< 40%: Không khí khô, có thể gây khô da, môi, kích ứng đường hô hấp. \n> 60%: Không khí ẩm, tạo điều kiện cho nấm mốc phát triển, gây dị ứng, các vấn đề về hô hấp.',
        suggestions: 'Duy trì độ ẩm ổn định. Sử dụng máy tạo ẩm nếu không khí quá khô, hoặc máy hút ẩm/thông gió nếu quá ẩm.',
        alertLevel: 'normal',
        alertMessage: ''
    };
    if (isNaN(value)) {
        data.statusText = 'Chưa có dữ liệu độ ẩm.';
        return data;
    }
    if (value < 40) {
        data = setAlertData(data, 'Thấp', `Hiện tại: ${value.toFixed(1)}%. Môi trường quá khô.`, 'LƯU Ý: Độ ẩm thấp! Có thể gây khô da, nứt nẻ môi, viêm họng.', 'Sử dụng máy tạo độ ẩm, đặt chậu nước trong phòng, thoa kem dưỡng ẩm.');
        data.alertLevel = 'warning';
        data.alertMessage = 'Quá khô!';
    } else if (value > 60) {
        data = setAlertData(data, 'Cao', `Hiện tại: ${value.toFixed(1)}%. Môi trường quá ẩm.`, 'LƯU Ý: Độ ẩm cao! Dễ phát sinh nấm mốc, gây dị ứng, khó chịu.', 'Sử dụng máy hút ẩm, bật điều hòa chế độ khô, đảm bảo thông gió tốt cho phòng.');
        data.alertLevel = 'warning';
        data.alertMessage = 'Quá ẩm!';
    }
    return data;
}

function getWeightData(value) { 
    const heightM = 1.65; 
    const bmi = isNaN(value) ? NaN : value / (heightM * heightM);
    
    let data = {
        title: 'Cân Nặng',
        value: value,
        statusText: `Hiện tại: ${isNaN(value) ? '--' : value.toFixed(1)} kg. ${!isNaN(bmi) ? `(BMI ước tính: ${bmi.toFixed(1)})` : ''}`,
        warning: '',
        healthy: 'BMI từ 18.5 - 24.9 được coi là bình thường. (Lưu ý: BMI chỉ là một chỉ số tham khảo).',
        unhealthy: 'BMI < 18.5: Thiếu cân. \nBMI 25 - 29.9: Thừa cân. \nBMI >= 30: Béo phì.',
        suggestions: 'Duy trì chế độ ăn uống cân bằng, giàu dinh dưỡng và tập thể dục đều đặn. Tham khảo ý kiến chuyên gia dinh dưỡng nếu có lo ngại về cân nặng.',
        alertLevel: 'normal',
        alertMessage: ''
    };

    if (isNaN(value)) {
        data.statusText = 'Chưa có dữ liệu cân nặng.';
        return data;
    }

    if (!isNaN(bmi)) {
        if (bmi < 18.5) {
            data = setAlertData(data, 'Thiếu cân', `Hiện tại: ${value.toFixed(1)} kg (BMI: ${bmi.toFixed(1)}). Cân nặng dưới mức khuyến nghị.`, 'CẢNH BÁO: Thiếu cân! Có thể là dấu hiệu của suy dinh dưỡng, ảnh hưởng đến sức đề kháng và năng lượng.', 'Tăng cường dinh dưỡng với thực phẩm giàu calo và protein. Tham khảo ý kiến bác sĩ hoặc chuyên gia dinh dưỡng.');
            data.alertLevel = 'danger';
            data.alertMessage = 'Thiếu cân!';
        } else if (bmi >= 25 && bmi < 30) {
            data = setAlertData(data, 'Thừa cân', `Hiện tại: ${value.toFixed(1)} kg (BMI: ${bmi.toFixed(1)}). Cân nặng trên mức khuyến nghị.`, 'LƯU Ý: Thừa cân! Tăng nguy cơ mắc các bệnh về tim mạch, tiểu đường type 2.', 'Điều chỉnh chế độ ăn uống lành mạnh hơn, giảm đồ ngọt, dầu mỡ. Tăng cường hoạt động thể chất.');
            data.alertLevel = 'warning';
            data.alertMessage = 'Thừa cân!';
        } else if (bmi >= 30) {
            data = setAlertData(data, 'Béo phì', `Hiện tại: ${value.toFixed(1)} kg (BMI: ${bmi.toFixed(1)}). Cân nặng ở mức béo phì.`, 'CẢNH BÁO: Béo phì! Nguy cơ cao mắc các bệnh mãn tính nguy hiểm. Cần can thiệp sớm.', 'Tham khảo ý kiến bác sĩ để có kế hoạch giảm cân an toàn và hiệu quả. Thay đổi lối sống tích cực.');
            data.alertLevel = 'danger';
            data.alertMessage = 'Béo phì!';
        } else {
             data.statusText += " Cân nặng trong khoảng bình thường.";
        }
    }
    return data;
}

function getHeartRateData(value) {
    let data = {
        title: 'Nhịp Tim',
        value: value,
        statusText: `Hiện tại: ${isNaN(value) ? '--' : Math.round(value)} bpm. Nhịp tim khi nghỉ ngơi.`,
        warning: '',
        healthy: '60 - 100 bpm (lần/phút): Nhịp tim bình thường khi nghỉ ngơi đối với người lớn.',
        unhealthy: '< 60 bpm: Nhịp tim chậm (Bradycardia). \n> 100 bpm: Nhịp tim nhanh (Tachycardia) khi nghỉ ngơi.',
        suggestions: 'Tập thể dục đều đặn để cải thiện sức khỏe tim mạch. Kiểm soát căng thẳng, ngủ đủ giấc. Hạn chế caffeine và chất kích thích.',
        alertLevel: 'normal',
        alertMessage: ''
    };
    if (isNaN(value)) {
        data.statusText = 'Chưa có dữ liệu nhịp tim.';
        return data;
    }
    const roundedValue = Math.round(value);
    if (roundedValue < 60) {
        data = setAlertData(data, 'Thấp', `Hiện tại: ${roundedValue} bpm. Nhịp tim chậm.`, 'CẢNH BÁO: Nhịp tim thấp! Nếu kèm theo triệu chứng như chóng mặt, mệt mỏi, khó thở, cần đi khám bác sĩ.', 'Tránh thay đổi tư thế đột ngột. Tham khảo ý kiến bác sĩ nếu tình trạng kéo dài hoặc có triệu chứng bất thường.');
        data.alertLevel = 'danger';
        data.alertMessage = 'Nhịp tim thấp!';
    } else if (roundedValue > 100) {
        data = setAlertData(data, 'Cao', `Hiện tại: ${roundedValue} bpm. Nhịp tim nhanh.`, 'CẢNH BÁO: Nhịp tim cao khi nghỉ! Có thể do căng thẳng, sốt, hoặc vấn đề tim mạch. Cần theo dõi và đi khám nếu kéo dài.', 'Nghỉ ngơi, hít thở sâu, uống đủ nước. Tránh các chất kích thích. Nếu không cải thiện, hãy đi khám bác sĩ.');
        data.alertLevel = 'danger';
        data.alertMessage = 'Nhịp tim cao!';
    } else {
        data.statusText += " Nhịp tim trong khoảng bình thường.";
    }
    return data;
}

function getSpO2Data(value) {
    let data = {
        title: 'SpO2 (Độ Bão Hòa Oxy Trong Máu)',
        value: value,
        statusText: `Hiện tại: ${isNaN(value) ? '--' : Math.round(value)}%. Mức oxy trong máu.`,
        warning: '',
        healthy: '95% - 100%: Mức oxy trong máu bình thường, cho thấy chức năng hô hấp tốt.',
        unhealthy: '< 95%: Thiếu oxy máu nhẹ. \n< 90%: Thiếu oxy máu nghiêm trọng, cần can thiệp y tế.',
        suggestions: 'Đảm bảo môi trường sống thông thoáng. Tập hít thở sâu. Nếu có bệnh lý hô hấp, tuân thủ điều trị của bác sĩ.',
        alertLevel: 'normal',
        alertMessage: ''
    };

    if (isNaN(value)) {
        data.statusText = 'Chưa có dữ liệu SpO2.';
        return data;
    }
    const roundedValue = Math.round(value);
    if (roundedValue < 90) {
        data = setAlertData(data, 'Rất Thấp', `Hiện tại: ${roundedValue}%. Mức oxy rất thấp!`, 'CẢNH BÁO NGHIÊM TRỌNG: SpO2 rất thấp! Đây là tình trạng khẩn cấp, cần tìm kiếm sự trợ giúp y tế ngay lập tức!', 'Gọi cấp cứu hoặc đến cơ sở y tế gần nhất. Trong khi chờ, cố gắng giữ bình tĩnh, hít thở sâu nếu có thể.');
        data.alertLevel = 'danger';
        data.alertMessage = 'SpO2 RẤT THẤP!';
    } else if (roundedValue < 95) {
        data = setAlertData(data, 'Thấp', `Hiện tại: ${roundedValue}%. Mức oxy hơi thấp.`, 'LƯU Ý: SpO2 thấp! Cần theo dõi sát. Nếu có triệu chứng khó thở, mệt mỏi, tím tái, cần đi khám ngay.', 'Nghỉ ngơi ở nơi thoáng khí. Nếu đang mắc bệnh hô hấp, liên hệ bác sĩ. Tránh gắng sức.');
        data.alertLevel = 'warning';
        data.alertMessage = 'SpO2 thấp!';
    } else {
         data.statusText += " Mức oxy trong máu bình thường.";
    }
    return data;
}

function setAlertData(data, statusOverride, statusText, warning, suggestions) {
    if (statusOverride) data.status = statusOverride;
    data.statusText = statusText;
    data.warning = warning;
    data.suggestions = suggestions;
    return data;
}

// Hàm cập nhật mẹo sức khỏe
function updateHealthTips() {
    const cards = document.querySelectorAll('.card');
    const tipsContent = document.getElementById('tips-content');
    if (!tipsContent) return;

    let tips = [];

    cards.forEach(card => {
        const metric = card.getAttribute('data-metric');
        const value = getValueFromCard(card); 

        const tip = generateHealthTip(metric, value);
        if (tip && tip.title) {
             tips.push(tip);
        }
    });

    tipsContent.innerHTML = tips.map(tip => `
        <div class="tip-card">
            <img src="${tip.image}" 
                 alt="Hình ảnh cho ${tip.title}" 
                 onerror="this.onerror=null; this.src='images/tips/placeholder.jpg'; this.alt='Lỗi tải hình ảnh: ${tip.title}';">
            <div class="tip-card-content">
                <h4>${tip.title}</h4>
                <p>${tip.description}</p>
            </div>
        </div>
    `).join('');
}

// Hàm sinh mẹo sức khỏe cho từng chỉ số
function generateHealthTip(metric, value) {
    let tip = {};
    const basePath = 'images/tips/'; // Đường dẫn cơ sở cho hình ảnh

     if (isNaN(value)) { 
        switch(metric) {
            case 'temperature': tip = { title: 'Nhiệt Độ Chung', description: 'Duy trì nhiệt độ phòng ổn định để tạo cảm giác thoải mái.', image: `${basePath}temperature_general.jpg` }; break;
            case 'humidity': tip = { title: 'Độ Ẩm Chung', description: 'Đảm bảo độ ẩm trong nhà không quá khô hoặc quá ẩm.', image: `${basePath}humidity_general.jpg` }; break;
            case 'weight': tip = { title: 'Cân Nặng & Vận Động', description: 'Kết hợp chế độ ăn uống lành mạnh với việc tập thể dục thường xuyên.', image: `${basePath}weight_general.jpg` }; break;
            case 'heartRate': tip = { title: 'Sức Khỏe Tim Mạch', description: 'Ngủ đủ giấc và quản lý căng thẳng để bảo vệ tim mạch.', image: `${basePath}heartrate_general.jpg` }; break;
            case 'spo2': tip = { title: 'Hô Hấp Khỏe Mạnh', description: 'Hít thở không khí trong lành và tránh xa khói thuốc.', image: `${basePath}spo2_general.jpg` }; break;
            default: return null;
        }
        return tip;
    }

    switch(metric) {
        case 'temperature':
            tip = generateTemperatureTip(value, basePath);
            break;
        case 'humidity':
            tip = generateHumidityTip(value, basePath);
            break;
        case 'weight':
            tip = generateWeightTip(value, basePath);
            break;
        case 'heartRate':
            tip = generateHeartRateTip(value, basePath);
            break;
        case 'spo2':
            tip = generateSpO2Tip(value, basePath);
            break;
        default:
            return null;
    }
    return tip;
}

// Các hàm sinh mẹo cụ thể, nhận basePath làm tham số
function generateTemperatureTip(value, basePath) {
    let tip = {
        title: 'Kiểm Soát Nhiệt Độ Phòng',
        description: 'Nhiệt độ phòng lý tưởng giúp bạn cảm thấy thoải mái và làm việc hiệu quả hơn. Hãy điều chỉnh cho phù hợp.',
        image: `${basePath}temperature_normal.jpg`
    };
    if (value < 20) {
        tip.description = 'Nhiệt độ hơi lạnh. Hãy mặc thêm áo ấm, uống một tách trà nóng hoặc sử dụng máy sưởi nhẹ nhàng.';
        tip.image = `${basePath}temperature_cold.jpg`;
    } else if (value > 28) {
        tip.description = 'Nhiệt độ khá nóng. Uống nhiều nước mát, sử dụng quạt hoặc điều hòa, và mặc quần áo thoáng khí.';
        tip.image = `${basePath}temperature_hot.jpg`;
    }
    return tip;
}

function generateHumidityTip(value, basePath) {
    let tip = {
        title: 'Duy Trì Độ Ẩm Cân Bằng',
        description: 'Độ ẩm phù hợp giúp bảo vệ da và hệ hô hấp. Không nên để không khí quá khô hoặc quá ẩm ướt.',
        image: `${basePath}humidity_normal.jpg`
    };
    if (value < 40) {
        tip.description = 'Không khí đang hơi khô. Bạn có thể dùng máy tạo ẩm hoặc đặt một bát nước gần nơi làm việc để cải thiện.';
         tip.image = `${basePath}humidity_dry.jpg`;
    } else if (value > 60) {
        tip.description = 'Độ ẩm hơi cao, có thể gây khó chịu. Hãy mở cửa sổ cho thông thoáng hoặc sử dụng máy hút ẩm.';
        tip.image = `${basePath}humidity_humid.jpg`;
    }
    return tip;
}

function generateWeightTip(value, basePath) {
    let tip = {
        title: 'Lối Sống Năng Động',
        description: 'Vận động thể chất thường xuyên và chế độ ăn uống cân đối là chìa khóa cho một cơ thể khỏe mạnh.',
        image: `${basePath}weight_normal.jpg`
    };
    const bmi = value / (1.65 * 1.65); // Giả định chiều cao, nên được điều chỉnh hoặc loại bỏ nếu không phù hợp
    if (bmi < 18.5 && !isNaN(bmi)) {
        tip.description = 'Cân nặng của bạn có vẻ hơi thấp. Hãy bổ sung thêm thực phẩm giàu dinh dưỡng và calo một cách lành mạnh.';
        tip.image = `${basePath}weight_under.jpg`;
    } else if (bmi > 25 && !isNaN(bmi)) {
        tip.description = 'Cân nặng của bạn có vẻ hơi cao. Tăng cường rau xanh, trái cây và các bài tập cardio nhẹ nhàng sẽ rất tốt.';
        tip.image = `${basePath}weight_over.jpg`;
    }
    return tip;
}

function generateHeartRateTip(value, basePath) {
    let tip = {
        title: 'Chăm Sóc Trái Tim Khỏe',
        description: 'Một trái tim khỏe mạnh là nền tảng của sức khỏe tốt. Hãy lắng nghe cơ thể và thư giãn khi cần thiết.',
        image: `${basePath}heartrate_normal.jpg`
    };
    if (value < 60 && !isNaN(value)) {
        tip.description = 'Nhịp tim của bạn có vẻ hơi chậm. Nếu cảm thấy mệt mỏi, hãy tham khảo ý kiến bác sĩ. Các bài tập nhẹ nhàng có thể hữu ích.';
        tip.image = `${basePath}heartrate_low.jpg`;
    } else if (value > 100 && !isNaN(value)) {
        tip.description = 'Nhịp tim của bạn có vẻ hơi nhanh khi nghỉ. Hãy thử các kỹ thuật thư giãn như hít thở sâu hoặc nghe nhạc nhẹ nhàng.';
        tip.image = `${basePath}heartrate_high.jpg`;
    }
    return tip;
}

function generateSpO2Tip(value, basePath) {
    let tip = {
        title: 'Hít Thở Sâu, Sống Khỏe',
        description: 'Duy trì mức oxy tốt trong máu là rất quan trọng. Không khí trong lành và các bài tập thở có thể giúp ích.',
        image: `${basePath}spo2_normal.jpg`
    };
    if (value < 95 && !isNaN(value)) {
        tip.description = 'Mức oxy của bạn hơi thấp. Hãy thử hít thở sâu ở nơi thoáng đãng. Nếu tình trạng kéo dài, nên đi khám bác sĩ.';
        tip.image = `${basePath}spo2_low.jpg`;
    }
    return tip;
}

// Hàm mới để cập nhật hiển thị cảnh báo trên card
function updateCardAlert(cardElement, metricName, value) {
    if (!cardElement) return;

    const metricData = getMetricData(metricName, value);
    const alertMessageElement = cardElement.querySelector('.card-alert-message');

    cardElement.classList.remove('alert', 'warning-state');
    if (alertMessageElement) {
        alertMessageElement.style.display = 'none';
        alertMessageElement.textContent = '';
    }

    if (isNaN(value)) { 
        return;
    }

    if (metricData.alertLevel === 'danger') {
        cardElement.classList.add('alert');
        if (alertMessageElement) {
            alertMessageElement.textContent = metricData.alertMessage;
            alertMessageElement.style.display = 'block';
        }
    } else if (metricData.alertLevel === 'warning') {
        cardElement.classList.add('warning-state');
        if (alertMessageElement) {
            alertMessageElement.textContent = metricData.alertMessage;
            alertMessageElement.style.display = 'block';
        }
    }
}