
package com.farmer.Farm_expense.CropCycle;

import org.springframework.stereotype.Service;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import com.farmer.Login_page.User;
import com.farmer.Login_page.UserRepository;
import com.farmer.add_region_page.FarmPage.Farm;
import com.farmer.add_region_page.FarmPage.FarmRepository;
import com.farmer.exception.ErrorException;

import java.time.LocalDate;
import java.util.List;

@Service
public class CropCycleService {

    private final CropCycleRepository cropcycleRepository;
    private final FarmRepository farmRepository;
    private final UserRepository userRepository;

    public CropCycleService(
            CropCycleRepository cropcycleRepository,
            FarmRepository farmRepository,
            UserRepository userRepository) {
        this.cropcycleRepository = cropcycleRepository;
        this.farmRepository = farmRepository;
        this.userRepository = userRepository;
    }

    // Get the currently logged-in user
    private User getLoggedInUser() {
        Authentication authentication =
                SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null
                || !authentication.isAuthenticated()
                || authentication.getName() == null
                || authentication.getName().equals("anonymousUser")) {
            throw new ErrorException("User is not authenticated");
        }

        return userRepository.findByEmailId(authentication.getName())
                .orElseThrow(() ->
                        new ErrorException("Logged-in user not found"));
    }

    // Find a farm only if it belongs to the logged-in user
    private Farm getOwnedFarm(Long farmId) {
        User user = getLoggedInUser();

        return farmRepository
                .findByIdAndUserId(farmId, user.getId())
                .orElseThrow(() ->
                        new ErrorException("Farm not found"));
    }

    // POST: Create a crop cycle for the user's own farm
    public CropCycleDTO addCrop(CropCycleDTO dto) {
        Farm farm = getOwnedFarm(dto.getFarmId());

        CropCycle cropcycle = CropCycleMapper.toENTITY(dto, farm);

        return CropCycleMapper.toDTO(
                cropcycleRepository.save(cropcycle));
    }

    // PUT: Complete a crop cycle only if its farm belongs to the user
    public CropCycle completeCrop(Long id, String endDate) {
        User user = getLoggedInUser();

        CropCycle crop = cropcycleRepository
                .findByIdAndFarmUserId(id, user.getId())
                .orElseThrow(() ->
                        new ErrorException("Crop cycle not found"));

        LocalDate date = LocalDate.parse(endDate);

        if (crop.getStartDate() != null
                && date.isBefore(crop.getStartDate())) {
            throw new ErrorException(
                    "End date cannot be before the start date");
        }

        crop.setEndDate(date);
        crop.setStatus("completed");

        return cropcycleRepository.save(crop);
    }

    // GET: Retrieve crop cycles only for the user's own farm
    public List<CropCycle> getCropsByFarm(Long farmId) {
        Farm farm = getOwnedFarm(farmId);

        return cropcycleRepository
                .findByFarm_IdOrderByStartDateDesc(farm.getId());
    }
}
